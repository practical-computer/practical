# frozen_string_literal: true

require "test_helper"

class MembershipInvitationMailerTest < ActionMailer::TestCase
  test "invitation" do
    invitation = users.invited_user_1.membership_invitations.first
    mail = MembershipInvitationMailer.invitation(
      membership_invitation: invitation
    )
    assert_equal "Invitation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "invitation_accepted" do
    invitation = users.invited_user_1.membership_invitations.first
    mail = MembershipInvitationMailer.invitation_accepted(
      membership_invitation: invitation
    )
    assert_equal "Invitation accepted", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
