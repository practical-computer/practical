# frozen_string_literal: true

require "application_system_test_case"

class User::EmergencyPasskeyRegistrationsTest < SlowBrowserSystemTestCase
  test "can emergency register a passkey" do
    user = users.user_1
    user.emergency_passkey_registrations.delete_all

    authenticator = add_virtual_authenticator

    visit new_user_emergency_passkey_registration_url

    fill_in "Email", with: user.email

    click_on "Get registration instructions"

    assert_current_path new_user_session_url

    assert_toast_message(text: I18n.translate("emergency_passkey_registrations.sent_message"))

    emergency_registration = user.emergency_passkey_registrations.reload.first

    token = emergency_registration.generate_token_for(:emergency_registration)

    visit user_emergency_passkey_registration_url(token)

    fill_in "Passkey label", with: Faker::Computer.stack

    click_button "Register passkey"

    assert_current_path new_user_session_url

    assert_toast_message(text: I18n.translate("emergency_passkey_registrations.registered_message"))

    fill_in "Email", with: user.email

    click_on "Sign in"

    assert_current_path root_url
  end
end
