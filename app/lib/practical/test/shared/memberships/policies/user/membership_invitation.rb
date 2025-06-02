# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Policies::User::MembershipInvitation
  extend ActiveSupport::Concern

  included do
    def assert_can_manage(invitation:, user:)
      assert_equal true, policy_for(invitation: invitation, user: user).apply(:manage?)
    end

    def assert_cannot_manage(invitation:, user:)
      assert_equal false, policy_for(invitation: invitation, user: user).apply(:manage?)
    end

    test "failing manage?: only true for the user's unused invitations" do
      seed "cases/membership_invitations"
      assert_can_manage(invitation: membership_invitations.one_invite_only, user: users.one_invite_only)
      assert_cannot_manage(invitation: membership_invitations.one_invite_only, user: users.invite_organization_1_manager)
    end

    test "manage?: only true for the user's unused invitations" do
      user = users.invited_user_1
      membership_invitation = find_membership_invitation!(email: user.email)
      assert_can_manage(invitation: membership_invitation, user: user)

      user = users.invited_user_2
      membership_invitation = find_membership_invitation!(email: user.email)
      assert_cannot_manage(invitation: membership_invitation, user: user)
    end
  end
end