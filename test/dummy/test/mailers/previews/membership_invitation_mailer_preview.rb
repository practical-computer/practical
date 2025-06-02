# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/membership_invitation_mailer
class MembershipInvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/membership_invitation_mailer/invitation
  def invitation
    MembershipInvitationMailer.invitation
  end

  # Preview this email at http://localhost:3000/rails/mailers/membership_invitation_mailer/invitation_accepted
  def invitation_accepted
    MembershipInvitationMailer.invitation_accepted
  end
end
