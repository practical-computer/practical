# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::EmergencyRegistration::Base
  extend ActiveSupport::Concern

  included do
    test "show: renders successfully when given an emergency_registration token for the resource's emergency registration class" do
      show_emergency_registration_action(token: valid_emergency_registration_token)
      assert_response :success
    end

    test "show: raises ActiveSupport::MessageVerifier::InvalidSignature if an expired token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        show_emergency_registration_action(token: expired_emergency_registration_token)
      end
    end

    test "show: raises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        show_emergency_registration_action(token: SecureRandom.hex)
      end
    end

    test "show: raises ActiveSupport::MessageVerifier::InvalidSignature if a raw emergency registration ID is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        show_emergency_registration_action(token: raw_emergency_registration_id)
      end
    end

    test "new_create_challenge: renders successfully when given a valid emergency_registration token for the resource's emergency registration class" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )
    end

    test "new_create_challenge: raises ActiveSupport::MessageVerifier::InvalidSignature if an expired token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        get_new_challenge_action(token: expired_emergency_registration_token)
      end
    end

    test "new_create_challenge: raises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        get_new_challenge_action(token: SecureRandom.hex)
      end
    end

    test "new_create_challenge: raises ActiveSupport::MessageVerifier::InvalidSignature if a raw emergency registration ID is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        get_new_challenge_action(token: raw_emergency_registration_id)
      end
    end

    test "use: registers a new passkey for the owner, using the client details" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: raw_credential)

      assert_difference "#{passkey_class}.count", +1 do
        use_emergency_registration_action(token: token, params: params)
        assert_successful_use_redirection
      end

      credential = hydrate_response_from_raw_credential(client: client, relying_party: webauthn_relying_party,
                                                        raw_credential: raw_credential).credential

      new_passkey = emergency_passkey_registration.reload.passkey
      assert_equal label, new_passkey.label
      assert_equal Base64.strict_encode64(credential.id), new_passkey.external_id
      assert_not_nil new_passkey.public_key
      assert_nil new_passkey.last_used_at
    end

    test "use: does not allow overriding who the passkey is registered for" do
      owner_instance
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_that_try_to_override_owner_during_emergency_registration(label: label,
                                                                               raw_credential: raw_credential)

      assert_difference "#{passkey_class}.count", +1 do
        use_emergency_registration_action(token: token, params: params)
        assert_successful_use_redirection
      end

      credential = hydrate_response_from_raw_credential(client: client, relying_party: webauthn_relying_party,
                                                        raw_credential: raw_credential).credential

      new_passkey = emergency_passkey_registration.reload.passkey
      assert_equal label, new_passkey.label
      assert_equal Base64.strict_encode64(credential.id), new_passkey.external_id
      assert_not_nil new_passkey.public_key
      assert_nil new_passkey.last_used_at

      assert_old_owner_owns_passkey(passkey: new_passkey)
    end

    test "use: raises ActiveRecord::RecordNotFound if an expired token is given" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: raw_credential)

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        use_emergency_registration_action(token: expired_emergency_registration_token, params: params)
      end
    end

    test "use: raises ActiveRecord::RecordNotFound if a bad token is given" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: raw_credential)

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        use_emergency_registration_action(token: SecureRandom.hex, params: params)
      end
    end

    test "use: raises ActiveRecord::RecordNotFound if a raw emergency registration ID is given" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: raw_credential)

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        use_emergency_registration_action(token: raw_emergency_registration_id, params: params)
      end
    end

    test "use: returns a unprocessable_entity with a form error if the passkey label is missing" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)

      params = params_for_using_emergency_passkey_registration(label: "    ", raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
        use_emergency_registration_action(token: token, params: params)
      end

      assert_response :unprocessable_entity

      assert_form_error_for_label(message: "can't be blank", type: :blank)
    end

    test "use: returns a unprocessable_entity with a form error if the passkey challenge fails" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = SecureRandom.hex
      client = webauthn_client

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: raw_credential)

      assert_no_difference "#{passkey_class}.count" do
        use_emergency_registration_action(token: token, params: params)
      end

      assert_response :unprocessable_entity

      assert_form_error_for_credential(message: I18n.translate("devise.emergency_passkey_registrations.webauthn_challenge_verification_error"))
    end

    test "use: returns a unprocessable_entity with a form error if the credential was missing" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: nil)

      assert_no_difference "#{passkey_class}.count" do
        use_emergency_registration_action(token: token, params: params)
      end

      assert_response :unprocessable_entity

      assert_form_error_for_credential(message: I18n.translate("devise.emergency_passkey_registrations.credential_missing_or_could_not_be_parsed"))
    end

    test "use: returns a unprocessable_entity with a form error if the credential could not be parsed" do
      emergency_passkey_registration = valid_emergency_registration
      assert_nil emergency_passkey_registration.used_at

      token = emergency_passkey_registration.generate_token_for(:emergency_registration)

      get_new_challenge_action(token: token)
      assert_response :ok

      assert_passkey_registration_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        relying_party_data: expected_relying_party_data,
        user_data: expected_user_data_for_challenge,
        credentials_to_exclude: expected_credentials_to_exclude
      )

      challenge = expected_stored_challenge
      client = webauthn_client

      create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = SecureRandom.hex

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: "blah")

      assert_no_difference "#{passkey_class}.count" do
        use_emergency_registration_action(token: token, params: params)
      end

      assert_response :unprocessable_entity

      assert_form_error_for_credential(message: I18n.translate("devise.emergency_passkey_registrations.credential_missing_or_could_not_be_parsed"))
    end
  end
end