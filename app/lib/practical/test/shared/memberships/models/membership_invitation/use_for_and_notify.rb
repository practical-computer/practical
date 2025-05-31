# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Models::MembershipInvitation::UseForAndNotify
  extend ActiveSupport::Concern

  included do
    test "use_for_and_notify!: raises AlreadyUsedError if a user is present" do
      invitation = instance_with_user

      assert_raises model_class::AlreadyUsedError do
        invitation.use_for_and_notify!(user: other_user)
      end
    end

    test "use_for_and_notify!: raises an ActiveRecord::RecordInvalid error if a membership already exists somehow for this user + organization" do
      user = invited_user_instance
      invitation = model_class.find_by!(email: user.email)

      invitation.organization.memberships.create!(
        user: user, membership_type: :staff, state: :pending_reacceptance
      )

      assert_raises ActiveRecord::RecordInvalid do
        invitation.use_for_and_notify!(user: user)
      end
    end

    test """use_for_and_notify!:
    - links to the given user
    - creates the Membership with the stored membership_type
    - matching mailer class: passkey_added
    """ do
      user = invited_user_instance

      invitation = model_class.find_by(email: user.email)

      assert_difference "Membership.count", +1 do
        invitation.use_for_and_notify!(user: user)
        invitation.reload

        assert_equal user, invitation.user
        assert_equal true, invitation.membership.active?
        assert_equal user, invitation.membership.user
        assert_equal invitation.organization, invitation.membership.organization
        additional_membership_accept_assertions(invitation: invitation)
      end

      assert_enqueued_email_with(
        mailer_class,
        :invitation_accepted,
        args: [{ membership_invitation: invitation }]
      )
    end
  end
end