# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Models::MembershipInvitation::Sending
  extend ActiveSupport::Concern

  included do
    test "belongs_to an sender" do
      reflection = model_class.reflect_on_association(sender_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "generates_token_for invitation that expires when the user is set" do
      instance = valid_new_instance
      instance.save!

      token = instance.generate_token_for(:invitation)

      assert_equal instance, model_class.find_by_token_for(:invitation, token)

      instance.update!(user: user_instance)

      assert_nil model_class.find_by_token_for(:invitation, token)
    end

    test "only validates that the sender has a membership in the organization on creation" do
      invitation = valid_new_instance
      other_user = other_user_instance_with_admin_privledges

      assert_not_includes other_user.organizations, invitation.organization

      invitation.sender = other_user

      assert_equal false, invitation.valid?
      assert_equal true, invitation.errors.of_kind?(:sender, :cannot_manage_organization)

      invitation.sender = other_user_instance_without_admin_privledges

      assert_equal false, invitation.valid?
      assert_equal true, invitation.errors.of_kind?(:sender, :cannot_manage_organization)

      invitation.sender = user_in_organization

      assert_equal true, invitation.valid?

      invitation.save!

      assert_equal true, invitation.valid?

      invitation.sender = other_user_instance_without_admin_privledges
      assert_equal true, invitation.valid?
    end

    test "can_be_resent?: has a 10 minute waiting period" do
      membership_invitation = model_class.first

      assert_nil membership_invitation.last_sent_at
      assert_equal true, membership_invitation.can_be_resent?

      time = Time.now.utc

      membership_invitation.update!(last_sent_at: time)

      Timecop.freeze(time + 2.minutes) do
        assert_equal false, membership_invitation.can_be_resent?
      end

      Timecop.freeze(time + 5.minutes) do
        assert_equal false, membership_invitation.can_be_resent?
      end

      Timecop.freeze(time + 10.minutes) do
        assert_equal true, membership_invitation.can_be_resent?
      end
    end
  end
end