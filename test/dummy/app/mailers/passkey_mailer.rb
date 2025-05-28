# frozen_string_literal: true

class PasskeyMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.passkey_mailer.passkey_added.subject
  #
  def passkey_added(passkey:)
    @passkey = passkey

    mail to: "to@example.org"
  end
end
