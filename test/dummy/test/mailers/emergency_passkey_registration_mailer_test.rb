require "test_helper"

class EmergencyPasskeyRegistrationMailerTest < ActionMailer::TestCase
  test "emergency_registration_request" do
    emergency_passkey_registration = users.user_1.emergency_passkey_registrations.first
    mail = EmergencyPasskeyRegistrationMailer.emergency_registration_request(
      emergency_passkey_registration: emergency_passkey_registration
    )
    assert_equal "Emergency registration request", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
