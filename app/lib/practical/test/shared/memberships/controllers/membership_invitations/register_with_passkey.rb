# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Controllers::MembershipInvitations::RegisterWithPasskey
  extend ActiveSupport::Concern

  included do
    test "new registration challenge action returns a registration challenge" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: visible_unused_token, params: params)
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
      new_registration_challenge_action(token: visible_unused_token, params: params)
      assert_response :bad_request
      assert_email_missing_error_message
    end

    test "new registration challenge action requires a passkey_label" do
      email = Faker::Internet.email
      passkey_label = "   "

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: visible_unused_token, params: params)
      assert_response :bad_request
      assert_passkey_label_missing_error_message
    end

    test "new registration challenge action returns 404 if a used membership_invitation token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: used_token, params: params)
      assert_response :not_found
    end

    test "new registration challenge action returns 404 if a hidden membership_invitation token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: hidden_token, params: params)
      assert_response :not_found
    end

    test "new registration challenge action aises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        new_registration_challenge_action(token: bad_token, params: params)
      end
    end

    test "new registration challenge action aises ActiveSupport::MessageVerifier::InvalidSignature if a raw token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        new_registration_challenge_action(token: raw_token, params: params)
      end
    end

    test "create_user_and_use: action creates a new resource and links the invitation to the resource" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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
      assert_difference "#{membership_class}.count", +1 do
        create_resource_action(token: token, params: params)
        assert_redirected_to create_resource_success_url
      end
      end
      end

      new_resource = resource_class.last
      credential = hydrate_response_from_raw_credential(client: client, relying_party: webauthn_relying_party,
                                                        raw_credential: raw_credential).credential

      new_passkey = new_resource.passkeys.last
      assert_equal passkey_label, new_passkey.label
      assert_equal Base64.strict_encode64(credential.id), new_passkey.external_id
      assert_not_nil new_passkey.public_key
      assert_nil new_passkey.last_used_at

      assert_resource_created_flash_message
      assert_user_created_and_membership_accepted
    end

    test "create_user_and_use: action does not create a duplicate resource" do
      email = resource_instance.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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
      assert_no_difference "#{membership_class}.count" do
        create_resource_action(token: token, params: params)
        assert_response :unprocessable_entity
      end
      end
      end
    end

    test "create_user_and_use: action requires an email" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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

      params = params_for_registration(email: "    ", passkey_label: passkey_label, raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
      assert_no_difference "#{membership_class}.count" do
        create_resource_action(token: token, params: params)
        assert_response :unprocessable_entity
      end
      end
      end
    end

    test "create_user_and_use: action requires a passkey_label" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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

      params = params_for_registration(email: email, passkey_label: "    ", raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
      assert_no_difference "#{membership_class}.count" do
        create_resource_action(token: token, params: params)
        assert_response :unprocessable_entity
      end
      end
      end
    end

    test "create_user_and_use: action requires a passkey_credential" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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

      params = params_for_registration(email: email, passkey_label: passkey_label, raw_credential: "    ")

      assert_no_difference "#{passkey_class}.count" do
      assert_no_difference "#{resource_class}.count" do
      assert_no_difference "#{membership_class}.count" do
      assert_raises NoMethodError do
        create_resource_action(token: token, params: params)
      end
      end
      end
      end
    end

    test "create_user_and_use: returns 404 if a used membership_invitation token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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
      assert_no_difference "#{membership_class}.count" do
        create_resource_action(token: used_token, params: params)
        assert_response :not_found
      end
      end
      end
    end

    test "create_user_and_use: returns 404 if a hidden membership_invitation token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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
      assert_no_difference "#{membership_class}.count" do
        create_resource_action(token: hidden_token, params: params)
        assert_response :not_found
      end
      end
      end
    end

    test "create_user_and_use: raises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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
      assert_no_difference "#{membership_class}.count" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        create_resource_action(token: bad_token, params: params)
      end
      end
      end
      end
    end

    test "create_user_and_use: raises ActiveSupport::MessageVerifier::InvalidSignature if a raw token is given" do
      email = Faker::Internet.email
      passkey_label = SecureRandom.hex
      token = visible_unused_token

      params = params_for_registration_challenge(email: email, passkey_label: passkey_label)
      new_registration_challenge_action(token: token, params: params)
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
      assert_no_difference "#{membership_class}.count" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        create_resource_action(token: raw_token, params: params)
      end
      end
      end
      end
    end
  end
end