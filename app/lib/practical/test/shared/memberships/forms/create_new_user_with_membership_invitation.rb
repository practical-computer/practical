# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Forms::CreateNewUserWithMembershipInvitation
  extend ActiveSupport::Concern

  included do
    def dummy_webauthn_credential
      OpenStruct.new(public_key: SecureRandom.hex, raw_id: SecureRandom.bytes(10), sign_count: 0)
    end

    test "save: merges errors from the attempted new user and re-raises" do
      membership_invitation = organizations.organization_3.membership_invitations.first
      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: membership_invitation.email,
        name: "    ",
        passkey_label: Faker::Computer.os,
        webauthn_credential: dummy_webauthn_credential
      )

      assert_no_difference "#{user_class}.count" do
      assert_no_difference "#{passkey_class}.count" do
      assert_raises ActiveRecord::RecordInvalid do
        form.save!
      end
      end
      end

      assert_equal true, form.errors.of_kind?(:name, :blank)
    end

    test "save: merges errors when trying to create a user with an existing email" do
      membership_invitation = organizations.organization_3.membership_invitations.first
      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: users.organization_1_manager.email,
        name: Faker::Name.name,
        passkey_label: Faker::Computer.os,
        webauthn_credential: dummy_webauthn_credential
      )

      assert_no_difference "#{user_class}.count" do
      assert_no_difference "#{passkey_class}.count" do
      assert_raises ActiveRecord::RecordInvalid do
        form.save!
      end
      end
      end

      assert_equal true, form.errors.of_kind?(:email, :taken)
    end

    test "save: merges errors from the attempted new passkey and re-raises" do
      membership_invitation = organizations.organization_3.membership_invitations.first

      credential = dummy_webauthn_credential
      credential.public_key =  "     "

      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: membership_invitation.email,
        name: Faker::Name.name,
        passkey_label: "   ",
        webauthn_credential: credential
      )

      assert_no_difference "#{user_class}.count" do
      assert_no_difference "#{passkey_class}.count" do
      assert_raises ActiveRecord::RecordInvalid do
        form.save!
      end
      end
      end

      assert_equal true, form.errors.of_kind?(:passkey_label, :blank)
      assert_equal true, form.errors.of_kind?(:public_key, :blank)
    end
    test "save: merges errors when trying to create a passkey that already exists" do
      membership_invitation = organizations.organization_3.membership_invitations.first

      credential = dummy_webauthn_credential
      credential.public_key = passkey_class.first.public_key

      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: membership_invitation.email,
        name: Faker::Name.name,
        passkey_label: Faker::Computer.os,
        webauthn_credential: credential
      )

      assert_no_difference "#{user_class}.count" do
      assert_no_difference "#{passkey_class}.count" do
      assert_raises ActiveRecord::RecordInvalid do
        form.save!
      end
      end
      end

      assert_equal true, form.errors.of_kind?(:public_key, :taken)
    end

    test "save: raises unexpected errors" do
      membership_invitation = organizations.organization_3.membership_invitations.first

      Spy.on(membership_invitation, :use_for_and_notify!).and_raise(ArgumentError)

      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: membership_invitation.email,
        name: Faker::Name.name,
        passkey_label: Faker::Computer.os,
        webauthn_credential: dummy_webauthn_credential
      )

      assert_no_difference "#{user_class}.count" do
      assert_no_difference "#{passkey_class}.count" do
      assert_raises ArgumentError do
        form.save!
      end
      end
      end
    end

    test "save: raises an AlreadyUsedError if the membership_invitation has a user" do
      membership_invitation = users.invited_user_2.membership_invitations.first

      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: Faker::Internet.email,
        name: Faker::Name.name,
        passkey_label: Faker::Computer.os,
        webauthn_credential: dummy_webauthn_credential
      )

      assert_no_difference "#{user_class}.count" do
      assert_no_difference "#{passkey_class}.count" do
      assert_raises MembershipInvitation::AlreadyUsedError do
        form.save!
      end
      end
      end
    end

    test """save:
      - creates the user with the given email & name
      - creates the passkey for the user
      - enqueues the email that the membership_invitation has been accepted
    """ do
      membership_invitation = organizations.organization_3.membership_invitations.first

      credential = dummy_webauthn_credential

      form = form_class.new(
        user: user_class.new(webauthn_id: SecureRandom.hex),
        membership_invitation: membership_invitation,
        email: membership_invitation.email,
        name: Faker::Name.name,
        passkey_label: Faker::Computer.os,
        webauthn_credential: credential
      )

      time = Time.now.utc

      Timecop.freeze(time) do
      assert_difference "#{user_class}.count", +1 do
      assert_difference "#{passkey_class}.count", +1 do
        form.save!
      end
      end
      end

      membership_invitation.reload

      new_user = form.user

      assert_equal true, new_user.persisted?
      assert_equal form.email, new_user.email
      assert_equal form.name, new_user.name

      assert_equal new_user, membership_invitation.user

      new_passkey = form.user.passkeys.first

      assert_equal true, new_passkey.persisted?
      assert_equal form.passkey_label, new_passkey.label
      assert_equal credential.public_key, new_passkey.public_key
      assert_equal time.to_formatted_s(:db), new_passkey.created_at.to_formatted_s(:db)
    end
  end
end