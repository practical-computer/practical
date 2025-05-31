# frozen_string_literal: true

require "test_helper"

class Users::PasskeysControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Shared::Auth::Passkeys::Controllers::PasskeyManagement::Base
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Helpers::Passkey::System::RackTest

  setup do
    get new_user_session_url
  end

  def resource_instance
    users.user_1
  end

  def create_additional_passkeys
    2.times do |n|
      resource_instance.passkeys.create!(
        label: [Faker::Computer.stack, n],
        external_id: SecureRandom.hex,
        public_key: SecureRandom.hex
      )
    end
  end

  def target_passkey
    resource_instance.passkeys.first
  end

  def delete_all_but_target_passkey
    resource_instance.passkeys.where.not(id: target_passkey.id).delete_all
  end

  def passkey_for_another_resource
    users.user_2.passkeys.first
  end

  def sign_in_as_resource
    sign_in(resource_instance)
  end

  def new_reauthentication_challenge_action
    post new_user_reauthentication_challenge_url
  end

  def reauthenticate_action(params:)
    post user_reauthentication_url, params: params, as: :json
  end

  def new_create_challenge_action(params:)
    post new_create_challenge_user_passkeys_url, params: params
  end

  def new_destroy_challenge_action(target_passkey:)
    post new_destroy_challenge_user_passkey_url(target_passkey)
  end

  def create_passkey_action(params:)
    post user_passkeys_url, params: params
  end

  def destroy_passkey_action(target_passkey:, params:)
    delete user_passkey_url(target_passkey), params: params
  end

  def expected_creation_stored_challenge
    session["user_passkey_creation_challenge"]
  end

  def expected_stored_reauthentication_challenge
    session["user_current_reauthentication_challenge"]
  end

  def expected_relying_party_data
    {"name"=> I18n.translate("app_title.text")}
  end

  def expected_user_data_for_challenge
    user_data(user: resource_instance)
  end

  def params_for_creating_passkey(label:, raw_credential:, reauthentication_token:)
    {
      passkey: {
        reauthentication_token: reauthentication_token,
        credential: JSON.generate(raw_credential),
        label: label
      }
    }
  end

  def params_that_try_to_override_owner_when_creating_passkey(label:, raw_credential:, reauthentication_token:)
    {
      passkey: {
        user_id: users.user_2,
        reauthentication_token: reauthentication_token,
        credential: JSON.generate(raw_credential),
        label: label
      }
    }
  end

  def params_for_create_passkey_challenge(label:)
    {
      passkey: {
        label: label
      }
    }
  end

  def params_for_destroying_passkey(reauthentication_token:)
    { passkey: { reauthentication_token: reauthentication_token} }
  end

  def assert_one_passkey_error_message
    expected = {"error" => I18n.translate("devise.passkeys.must_be_at_least_one_passkey")}
    assert_equal expected, response.parsed_body
  end

  def assert_not_reauthenticated_message
    expected = {"error" => I18n.translate("devise.passkeys.not_reauthenticated")}
    assert_equal expected, response.parsed_body
  end

  def assert_reauthentication_token_challenge
    assert_passkey_authentication_challenge(
      data: response.parsed_body,
      stored_challenge: expected_stored_reauthentication_challenge,
      credentials_to_allow: resource_instance.passkeys
    )
  end

  def assert_new_creation_challenge
    existing_passkeys = resource_instance.passkeys.map{|x| credential_data_for_passkey(passkey: x)}

    assert_passkey_registration_challenge(
      data: response.parsed_body,
      stored_challenge: expected_creation_stored_challenge,
      relying_party_data: expected_relying_party_data,
      user_data: expected_user_data_for_challenge,
      credentials_to_exclude: existing_passkeys
    )
  end

  def assert_new_destroy_challenge
    existing_passkeys = (resource_instance.passkeys - [target_passkey])

    assert_passkey_authentication_challenge(
      data: response.parsed_body,
      stored_challenge: expected_stored_reauthentication_challenge,
      credentials_to_allow: existing_passkeys
    )
  end

  def assert_create_redirect
    assert_redirected_to edit_user_registration_url
  end

  def assert_destroy_redirect
    assert_redirected_to edit_user_registration_url
  end

  def resource_webauthn_client
    user_webauthn_client
  end

  def create_passkey_for_resource_and_return_webauthn_credential(resource:)
    create_passkey_for_user_and_return_webauthn_credential(user: resource)
  end

  def passkey_class
    Passkey
  end

  def webauthn_relying_party
    relying_party
  end

  def get_reauthentication_token
    session["user_current_reauthentication_token"]
  end

  alias_method :expected_stored_reauthentication_token, :get_reauthentication_token

  def assert_form_error_for_blank_label
    assert_error_json_contains(
      container_id: "passkey_label_errors",
      element_id: "passkey_label",
      message: "can't be blank",
      type: "blank"
    )
  end

  def assert_form_error_for_taken_label
    assert_error_json_contains(
      container_id: "passkey_label_errors",
      element_id: "passkey_label",
      message: "has already been taken",
      type: "taken"
    )
  end
end
