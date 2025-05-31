# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Forms::Organization::NewMembershipInvitation
  extend ActiveSupport::Concern

  included do
    test "save!: raises a validation error if the email is blank" do
      form = form_class.new(email: "    ")
      assert_raises ActiveModel::ValidationError do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:email, :blank)
    end

    test "save!: raises a validation error if the current_organization is missing" do
      form = form_class.new(current_organization: nil)
      assert_raises ActiveModel::ValidationError do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:current_organization, :blank)
    end

    test "save!: raises validation errors from the underlying MembershipInvitation object" do
      form = form_class.new(email: Faker::Internet.email,
                                                           current_organization: organizations.organization_1,
                                                           sender: users.organization_2_owner,
                                                           membership_type: :organization_manager
                                                          )

      assert_raises ActiveRecord::RecordInvalid do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:sender, :cannot_manage_organization)
    end

    test "save!: creates a new MembershipInvitation and enqueues the email" do
      email = Faker::Internet.email
      form = form_class.new(email: email,
                                                           current_organization: organizations.organization_1,
                                                           sender: users.organization_1_manager,
                                                           membership_type: :staff
                                                          )

      time = Time.now.utc

      assert_difference "#{membership_invitation_class}.count", +1 do
      assert_no_difference "#{membership_class}.count" do
      Timecop.freeze(time) do
        form.save!
      end
      end
      end

      assert_equal email, form.invitation.email
      assert_equal "staff", form.invitation.membership_type
      assert_equal organizations.organization_1, form.invitation.organization
      assert_equal users.organization_1_manager, form.invitation.sender

      assert_enqueued_email_with(MembershipInvitationMailer, :invitation, args: [{membership_invitation: form.invitation}])
      assert_equal time.to_fs(:db), form.invitation.last_sent_at.to_fs(:db)
    end

    test "save!: re-sends a MembershipInvitation where we can re-send the email" do
      email = Faker::Internet.email

      existing_invitation = organizations.organization_1.membership_invitations.create!(email: email, sender: users.organization_1_owner, membership_type: :organization_manager)

      form = form_class.new(email: email,
                                                           current_organization: organizations.organization_1,
                                                           sender: users.organization_1_manager,
                                                           membership_type: :staff
                                                          )

      time = Time.now.utc

      assert_no_difference "#{membership_invitation_class}.count" do
      assert_no_difference "#{membership_class}.count" do
      Timecop.freeze(time) do
        form.save!
      end
      end
      end

      assert_equal email, form.invitation.email
      assert_equal "organization_manager", form.invitation.membership_type
      assert_equal organizations.organization_1, form.invitation.organization
      assert_equal users.organization_1_owner, form.invitation.sender

      assert_enqueued_email_with(MembershipInvitationMailer, :invitation, args: [{membership_invitation: existing_invitation}])
      assert_equal time.to_fs(:db), form.invitation.last_sent_at.to_fs(:db)
    end

    test "save!: returns an error if the MembershipInvitation cannot be re-sent" do
      user = users.organization_1_staff
      email = user.email
      existing_invitation = organizations.organization_1.membership_invitations.create!(email: email, sender: users.organization_1_manager, membership_type: :staff, user: user)

      form = form_class.new(email: email,
                                                           current_organization: organizations.organization_1,
                                                           sender: users.organization_1_manager,
                                                           membership_type: :staff
                                                          )

      assert_no_difference "#{membership_invitation_class}.count" do
      assert_no_difference "#{membership_class}.count" do
      assert_raises ActiveModel::ValidationError do
        form.save!
      end
      end
      end

      assert_equal true, form.errors.of_kind?(:base, :cannot_be_resent)
      assert_no_enqueued_emails
    end

    test "save!: returns an error if the Membership is archived_by_user" do
      user = users.organization_1_staff
      email = user.email
      organization = organizations.organization_2

      existing_membership = user.memberships.find_by!(organization: organization)
      existing_membership.update!(state: :archived_by_user)

      form = form_class.new(email: email,
                                                           current_organization: organizations.organization_2,
                                                           sender: users.organization_2_owner,
                                                           membership_type: :staff
                                                          )

      assert_no_difference "#{membership_invitation_class}.count" do
      assert_no_difference "#{membership_class}.count" do
      assert_raises ActiveModel::ValidationError do
        form.save!
      end
      end
      end

      assert_equal true, form.errors.of_kind?(:base, :cannot_be_resent)
      assert_no_enqueued_emails
    end

    test "save!: transitions an archived_by_organization Membership to pending_reacceptance and stores the underlying membership" do
      user = users.retired_staff
      email = user.email
      organization = organizations.organization_1

      existing_membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(email: email,
                                                           current_organization: organizations.organization_1,
                                                           sender: users.organization_1_manager,
                                                           membership_type: :staff
                                                          )

      assert_no_difference "#{membership_invitation_class}.count" do
      assert_no_difference "#{membership_class}.count" do
        form.save!
      end
      end

      assert_equal existing_membership, form.existing_membership
      assert_nil form.invitation
      assert_equal "pending_reacceptance", form.existing_membership.state
      assert_no_enqueued_emails
    end

    test "save!: does nothing to an already active Membership and stores the underlying membership" do
      user = users.works_at_org_1_and_2
      email = user.email
      organization = organizations.organization_1

      existing_membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(email: email,
                                                           current_organization: organizations.organization_1,
                                                           sender: users.organization_1_manager,
                                                           membership_type: :staff
                                                          )

      assert_no_difference "#{membership_invitation_class}.count" do
      assert_no_difference "#{membership_class}.count" do
        form.save!
      end
      end

      assert_equal existing_membership, form.existing_membership
      assert_nil form.invitation
      assert_equal "active", form.existing_membership.state
      assert_no_enqueued_emails
    end
  end
end