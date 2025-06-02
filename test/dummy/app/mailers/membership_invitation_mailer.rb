# frozen_string_literal: true

class MembershipInvitationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.membership_invitation_mailer.invitation.subject
  #
  def invitation(membership_invitation:)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.membership_invitation_mailer.invitation_accepted.subject
  #
  def invitation_accepted(membership_invitation:)
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
