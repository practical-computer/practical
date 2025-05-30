require "test_helper"

class SendEmergencyPasskeyRegistrationServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Auth::Passkeys::Services::SendEmergencyRegistration

  def assert_successful_run(service:)
    assert_difference "EmergencyPasskeyRegistration.count", +1 do
      service.run!
    end
    assert_enqueued_email_with(
      mailer_class,
      :emergency_registration_request,
      args: [{ emergency_passkey_registration: service.emergency_registration }]
    )
  end

  def service_class
    SendEmergencyPasskeyRegistrationService
  end

  def mailer_class
    EmergencyPasskeyRegistrationMailer
  end

  def valid_email
    users.user_1.email
  end
end