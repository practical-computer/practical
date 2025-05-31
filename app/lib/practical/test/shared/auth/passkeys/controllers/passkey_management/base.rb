# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::PasskeyManagement::Base
  extend ActiveSupport::Concern

  included do
    test "new create challenge creates a new registration challenge that excludes any existing credentials" do
      sign_in_as_resource
      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge
    end

    test "new destroy challenge creates a new authentication challenge that includes all passkeys but the target passkey" do
      sign_in_as_resource
      create_additional_passkeys
      assert_destroy_challenge_authorized do
        new_destroy_challenge_action(target_passkey: target_passkey)
      end

      assert_response :ok
      assert_new_destroy_challenge
    end

    test "new destroy challenge returns an error if there's only 1 passkey" do
      sign_in_as_resource
      new_destroy_challenge_action(target_passkey: target_passkey)

      assert_response :bad_request
      assert_one_passkey_error_message
    end

    test "create adds the given credential as a passkey after reauthenticating" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_reauthentication_challenge_authorized do
        new_reauthentication_challenge_action
      end
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge

      challenge = expected_creation_stored_challenge
      reauthentication_token = expected_stored_reauthentication_token

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = Faker::Computer.os

      params = params_for_creating_passkey(label: label, raw_credential: raw_credential,
                                           reauthentication_token: reauthentication_token)

      assert_difference "#{passkey_class}.count", +1 do
      assert_create_authorized do
          create_passkey_action(params: params)
        assert_create_redirect
      end
      end

      credential = hydrate_response_from_raw_credential(client: client, relying_party: webauthn_relying_party,
                                                        raw_credential: raw_credential).credential

      new_passkey = resource_instance.passkeys.last
      assert_equal label, new_passkey.label
      assert_equal Base64.strict_encode64(credential.id), new_passkey.external_id
      assert_not_nil new_passkey.public_key
      assert_nil new_passkey.last_used_at
    end

    test "create does not allow overriding who the passkey is for" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_reauthentication_challenge_authorized do
        new_reauthentication_challenge_action
      end
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge

      challenge = expected_creation_stored_challenge
      reauthentication_token = expected_stored_reauthentication_token

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = Faker::Computer.os

      params = params_that_try_to_override_owner_when_creating_passkey(label: label, raw_credential: raw_credential,
                                                                       reauthentication_token: reauthentication_token)

      assert_difference "#{passkey_class}.count", +1 do
      assert_create_authorized do
        create_passkey_action(params: params)
        assert_create_redirect
      end
      end

      credential = hydrate_response_from_raw_credential(client: client, relying_party: webauthn_relying_party,
                                                        raw_credential: raw_credential).credential

      new_passkey = resource_instance.passkeys.last
      assert_equal label, new_passkey.label
      assert_equal Base64.strict_encode64(credential.id), new_passkey.external_id
      assert_not_nil new_passkey.public_key
      assert_nil new_passkey.last_used_at
    end

    test "create requires a reauthentication token to be provided" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_reauthentication_challenge_authorized do
        new_reauthentication_challenge_action
      end
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge

      challenge = expected_creation_stored_challenge
      reauthentication_token = "     "

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = Faker::Computer.os

      params = params_for_creating_passkey(label: label, raw_credential: raw_credential,
                                           reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count", +1 do
        create_passkey_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end
    end

    test "create returns an error if the reauthentication_token is bad" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_reauthentication_challenge_authorized do
        new_reauthentication_challenge_action
      end
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge

      challenge = expected_creation_stored_challenge
      reauthentication_token = SecureRandom.hex

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = Faker::Computer.os

      params = params_for_creating_passkey(label: label, raw_credential: raw_credential,
                                           reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count", +1 do
        create_passkey_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end
    end

    test "create returns an error if the passkey_label is missing" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_reauthentication_challenge_authorized do
        new_reauthentication_challenge_action
      end
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge

      challenge = expected_creation_stored_challenge
      reauthentication_token = expected_stored_reauthentication_token

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = "    "

      params = params_for_creating_passkey(label: label, raw_credential: raw_credential,
                                           reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count", +1 do
      assert_create_authorized do
        create_passkey_action(params: params)
      end
      end

      assert_response :unprocessable_entity
      assert_form_error_for_blank_label
    end

    test "create returns an error if the passkey_label is a duplicate" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_reauthentication_challenge_authorized do
        new_reauthentication_challenge_action
      end
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      params = params_for_create_passkey_challenge(label: Faker::Computer.os)
      assert_create_challenge_authorized do
        new_create_challenge_action(params: params)
      end
      assert_response :ok
      assert_new_creation_challenge

      challenge = expected_creation_stored_challenge
      reauthentication_token = expected_stored_reauthentication_token

      raw_credential = create_credential_and_return_payload_from_challenge(client: client, challenge: challenge)
      label = target_passkey.label

      params = params_for_creating_passkey(label: label, raw_credential: raw_credential,
                                           reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count", +1 do
      assert_create_authorized do
        create_passkey_action(params: params)
      end
      end

      assert_response :unprocessable_entity
      assert_form_error_for_taken_label
    end

    test "destroy deletes the given passkey" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_destroy_challenge_authorized do
        new_destroy_challenge_action(target_passkey: target_passkey)
      end
      assert_response :ok
      assert_new_destroy_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      passkey = target_passkey
      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_destroying_passkey(reauthentication_token: reauthentication_token)

      assert_difference "#{passkey_class}.count", -1 do
      assert_destroy_authorized do
        destroy_passkey_action(target_passkey: passkey, params: params)
      end
      end

      assert_nil passkey_class.find_by(id: passkey.id)
      assert_destroy_redirect
    end

    test "destroy requires a reauthentication token to be present" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_destroy_challenge_authorized do
        new_destroy_challenge_action(target_passkey: target_passkey)
      end
      assert_response :ok
      assert_new_destroy_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)
      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      passkey = target_passkey
      reauthentication_token = "    "
      params = params_for_destroying_passkey(reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count" do
        destroy_passkey_action(target_passkey: passkey, params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      assert_not_nil passkey_class.find_by(id: passkey.id)
    end

    test "destroy return an error if the reauthentication token is bad" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_destroy_challenge_authorized do
        new_destroy_challenge_action(target_passkey: target_passkey)
      end
      assert_response :ok
      assert_new_destroy_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      passkey = target_passkey
      reauthentication_token = SecureRandom.hex
      params = params_for_destroying_passkey(reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count" do
        destroy_passkey_action(target_passkey: passkey, params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      assert_not_nil passkey_class.find_by(id: passkey.id)
    end

    test "destroy does not delete a passkey for another resource" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_destroy_challenge_authorized do
        new_destroy_challenge_action(target_passkey: target_passkey)
      end
      assert_response :ok
      assert_new_destroy_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      passkey = passkey_for_another_resource
      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_destroying_passkey(reauthentication_token: reauthentication_token)

      assert_no_difference "#{passkey_class}.count" do
        destroy_passkey_action(target_passkey: passkey, params: params)
        assert_response :not_found
      end

      assert_not_nil passkey_class.find_by(id: passkey.id)
    end

    test "destroy returns an error if there's only 1 passkey" do
      sign_in_as_resource

      client = resource_webauthn_client
      create_passkey_for_resource_and_return_webauthn_credential(resource: resource_instance)

      assert_destroy_challenge_authorized do
        new_destroy_challenge_action(target_passkey: target_passkey)
      end
      assert_response :ok
      assert_new_destroy_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      passkey = target_passkey
      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_destroying_passkey(reauthentication_token: reauthentication_token)

      delete_all_but_target_passkey

      assert_no_difference "#{passkey_class}.count" do
        destroy_passkey_action(target_passkey: passkey, params: params)
        assert_response :bad_request
        assert_one_passkey_error_message
      end

      assert_not_nil passkey_class.find_by(id: passkey.id)
    end
  end
end