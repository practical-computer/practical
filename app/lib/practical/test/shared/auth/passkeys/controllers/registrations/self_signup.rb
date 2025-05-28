# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Registrations::SelfSignup
  extend ActiveSupport::Concern

  included do
    test "new registration challenge action returns a registration challenge" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :ok
      webauthn_id = response.parsed_body["user"]["id"]
      user_data = expected_user_data_for_challenge(email: email, webauthn_id: webauthn_id, name: email)

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: user_data,
        credentials_to_exclude: []
      )
    end

    test "new registration challenge action requires an email" do
      email = ""
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :bad_request
      assert_email_missing_error_message
    end

    test "new registration challenge action requires a passkey_label" do
      email = Faker::Internet.email
      passkey_label = "   "

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :bad_request
      assert_passkey_label_missing_error_message
    end

    test "new registration action renders successfully" do
      new_registration_action
      assert_response :ok
    end

    test "create registration action creates a new resource" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :ok
      webauthn_id = response.parsed_body["user"]["id"]
      user_data = expected_user_data_for_challenge(email: email, webauthn_id: webauthn_id, name: email)

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: user_data,
        credentials_to_exclude: []
      )

      client = webauthn_client
      challenge = expected_stored_challenge
      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)

      params = params_for_registration(email: email, passkey_label: passkey_label, raw_credential: raw_credential)

      assert_difference "#{passkey_class}.count", +1 do
      assert_difference "#{resource_class}.count", +1 do
        create_resource_action(params: params)
        assert_redirected_to expected_success_url
      end
      end

      new_resource = resource_class.last
      credential = hydrate_response_from_raw_credential(client: client, relying_party: webauthn_relying_party, raw_credential: raw_credential).credential

      new_passkey = new_resource.passkeys.last
      assert_equal passkey_label, new_passkey.label
      assert_equal Base64.strict_encode64(credential.id), new_passkey.external_id
      assert_not_nil new_passkey.public_key
      assert_not_nil new_passkey.last_used_at
    end

    test "create registration action does not create a duplicate resource" do
      email = existing_resource.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :ok
      webauthn_id = response.parsed_body["user"]["id"]
      user_data = expected_user_data_for_challenge(email: email, webauthn_id: webauthn_id, name: email)

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: user_data,
        credentials_to_exclude: []
      )

      client = webauthn_client
      challenge = expected_stored_challenge
      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)

      params = params_for_registration(email: email, passkey_label: passkey_label, raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
        create_resource_action(params: params)
        assert_response :unprocessable_entity
      end
      end
    end

    test "create registration action requires an email" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :ok
      webauthn_id = response.parsed_body["user"]["id"]
      user_data = expected_user_data_for_challenge(email: email, webauthn_id: webauthn_id, name: email)

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: user_data,
        credentials_to_exclude: []
      )

      client = webauthn_client
      challenge = expected_stored_challenge
      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)

      params = params_for_registration(email: "   ", passkey_label: passkey_label, raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
        create_resource_action(params: params)
        assert_response :bad_request
      end
      end
    end

    test "create registration action requires a passkey_label" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :ok
      webauthn_id = response.parsed_body["user"]["id"]
      user_data = expected_user_data_for_challenge(email: email, webauthn_id: webauthn_id, name: email)

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: user_data,
        credentials_to_exclude: []
      )

      client = webauthn_client
      challenge = expected_stored_challenge
      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)

      params = params_for_registration(email: email, passkey_label: "   ", raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
        create_resource_action(params: params)
        assert_response :bad_request
      end
      end
    end

    test "create registration action requires a passkey_credential" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(params: params)
      assert_response :ok
      webauthn_id = response.parsed_body["user"]["id"]
      user_data = expected_user_data_for_challenge(email: email, webauthn_id: webauthn_id, name: email)

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: user_data,
        credentials_to_exclude: []
      )

      client = webauthn_client
      challenge = expected_stored_challenge
      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)

      params = params_for_registration(email: email, passkey_label: passkey_label, raw_credential: "   ")

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
      assert_raises NoMethodError do
        create_resource_action(params: params)
      end
      end
      end
    end
  end
end