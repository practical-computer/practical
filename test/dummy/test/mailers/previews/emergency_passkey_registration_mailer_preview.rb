# Preview all emails at http://localhost:3000/rails/mailers/emergency_passkey_registration_mailer
class EmergencyPasskeyRegistrationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/emergency_passkey_registration_mailer/emergency_registration_request
  def emergency_registration_request
    EmergencyPasskeyRegistrationMailer.emergency_registration_request(
      emergency_passkey_registration: EmergencyPasskeyRegistration.last
    )
  end
end
