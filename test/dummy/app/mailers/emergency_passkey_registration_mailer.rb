class EmergencyPasskeyRegistrationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.emergency_passkey_registration_mailer.emergency_registration_request.subject
  #
  def emergency_registration_request(emergency_passkey_registration:)
    @greeting = "Hi"
    token = emergency_passkey_registration.generate_token_for(:emergency_registration)
    @action_url = user_emergency_passkey_registration_url(token)

    mail to: "to@example.org"
  end
end
