# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Registrations::SelfDestroy
  extend ActiveSupport::Concern

  included do
    test "destroy deletes the given resource when reauthenticated" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

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

      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_destruction(reauthentication_token: reauthentication_token)

      resource_id = resource_instance.id

      assert_difference "#{resource_class}.count", -1 do
      assert_destroy_authorized do
        destroy_registration_action(params: params)
        assert_redirected_to destroy_success_url
      end
      end

      assert_nil resource_class.find_by(id: resource_id)
    end

    test "destroy requires a reauthentication token" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

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

      reauthentication_token = "   "
      params = params_for_destruction(reauthentication_token: reauthentication_token)

      resource_id = resource_instance.id

      assert_no_difference "#{resource_class}.count" do
        destroy_registration_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      assert_not_nil resource_class.find_by(id: resource_id)
    end

    test "destroy requires the reauthentication token to match the stored value" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

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

      reauthentication_token = SecureRandom.hex
      params = params_for_destruction(reauthentication_token: reauthentication_token)

      resource_id = resource_instance.id

      assert_no_difference "#{resource_class}.count" do
        destroy_registration_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      assert_not_nil resource_class.find_by(id: resource_id)
    end

    test "destroy ignores an attmept to delete a different resource" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

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

      reauthentication_token = "   "
      params = params_trying_to_destroy_other_resource(reauthentication_token: reauthentication_token)

      resource_id = resource_instance.id

      assert_no_difference "#{resource_class}.count" do
        destroy_registration_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      assert_not_nil resource_class.find_by(id: resource_id)
    end
  end
end