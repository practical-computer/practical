# frozen_string_literal: true

require "test_helper"

class Users::EmergencyPasskeyRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Shared::Auth::Passkeys::Controllers::EmergencyRegistration::Base
  include Practical::Test::Shared::Auth::Passkeys::Controllers::EmergencyRegistration::SelfService
  include Practical::Test::Shared::Auth::Passkeys::Controllers::EmergencyRegistration::CrossPollination

  def owner_instance
    users.user_1
  end

  def get_new_registration_action(**options)
    get new_user_emergency_passkey_registration_url, **options
  end

  def request_emergency_registration_action(**options)
    post user_emergency_passkey_registrations_url, **options
  end

  def expected_new_session_url
    new_user_session_url
  end

  def send_registration_service_class
    SendEmergencyPasskeyRegistrationService
  end

  def valid_emergency_registration
    users.user_1.emergency_passkey_registrations.first
  end

  def valid_emergency_registration_token
    valid_emergency_registration.generate_token_for(:emergency_registration)
  end

  def valid_emergency_registration_token_for_other_resource
    moderators.moderator_1.emergency_passkey_registrations.first.generate_token_for(:emergency_registration)
  end

  def expired_emergency_registration_token
    token = nil
    Timecop.freeze(1.month.ago) do
      token = valid_emergency_registration.generate_token_for(:emergency_registration)
    end

    return token
  end

  def raw_emergency_registration_id
    valid_emergency_registration.id
  end

  def show_emergency_registration_action(token:)
    get user_emergency_passkey_registration_url(token)
  end

  def get_new_challenge_action(token:)
    post new_challenge_user_emergency_passkey_registration_url(token), as: :json
  end

  def expected_stored_challenge
    session["user_emergency_passkey_creation_challenge"]
  end

  def expected_relying_party_data
    {"name"=> I18n.translate("app_title.text")}
  end

  def expected_user_data_for_challenge
    user_data(user: users.user_1)
  end

  def expected_credentials_to_exclude
    users.user_1.passkeys.map{|x| credential_data_for_passkey(passkey: x) }
  end

  def webauthn_client
    fake_client(origin: relying_party_origin)
  end

  def params_for_using_emergency_passkey_registration(label:, raw_credential:)
    {
      emergency_passkey_registration_form: {
        passkey_credential: JSON.generate(raw_credential),
        passkey_label: label
      }
    }
  end

  def params_that_try_to_override_owner_during_emergency_registration(label:, raw_credential:)
    {
      emergency_passkey_registration_form: {
        passkey_credential: JSON.generate(raw_credential),
        passkey_label: label,
        user_id: users.user_2.id
      }
    }
  end

  def assert_old_owner_owns_passkey(passkey:)
    assert_equal owner_instance, passkey.user
  end

  def passkey_class
    Passkey
  end

  def webauthn_relying_party
    relying_party
  end

  def assert_registration_sent_redirection
    assert_redirected_to new_user_session_url
  end

  def assert_successful_use_redirection
    assert_json_redirected_to new_user_session_url
  end

  def use_emergency_registration_action(token:, params:)
    patch use_user_emergency_passkey_registration_url(id: token), params: params
  end

  def assert_form_error_for_credential(message:)
    assert_error_json_contains(
      container_id: "emergency_passkey_registration_form_passkey_credential_errors",
      element_id: "emergency_passkey_registration_form_passkey_credential",
      message: message,
      type: message
    )
  end

  def assert_form_error_for_label(message:, type:)
    assert_error_json_contains(
      container_id: "emergency_passkey_registration_form_passkey_label_errors",
      element_id: "emergency_passkey_registration_form_passkey_label",
      message: message,
      type: type.to_s
    )
  end
end
