# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Reauthentication::Base
  extend ActiveSupport::Concern

  included do
    test "new_challenge: requires the resource to be authenticated" do
      issue_new_challenge_action
      assert_response :not_found
    end

    test "new_challenge: sets the session variable that stores the new challenge" do
      sign_in_as_resource
      assert_new_challenge_authorized do
        issue_new_challenge_action
      end
      assert_response :ok
      assert_equal get_session_challenge, response.parsed_body["challenge"]
    end

    test "new_challenge: overrides the session variable that stores the new challenge" do
      sign_in_as_resource
      assert_new_challenge_authorized do
        issue_new_challenge_action
      end
      assert_response :ok
      old_session_challenge = get_session_challenge

      assert_new_challenge_authorized do
        issue_new_challenge_action
      end
      assert_response :ok

      assert_not_equal old_session_challenge, get_session_challenge
      assert_not_equal old_session_challenge, response.parsed_body["challenge"]
    end

    test "reauthenticate: requires the resource to be authenticated" do
      reauthenticate_action(params: {})
      assert_response :not_found
    end

    test """reauthenticate:
      - verifies that the given challenge matches what is in the session
      - clears the challenge session variable
      - returns the reauthentication_token
      - stores the reauthentication_token in the session
    """ do
      sign_in_as_resource
      assert_new_challenge_authorized do
        issue_new_challenge_action
      end
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: expected_credentials_to_allow
      )

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :ok

      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil get_session_challenge
    end

    test """reauthenticate:
      - raises an error if the challenge does not match what is in the session
      - clears the challenge session variable
      - does not have a reauthentication_token in the session
    """ do
      sign_in_as_resource
      assert_new_challenge_authorized do
        issue_new_challenge_action
      end
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: expected_credentials_to_allow
      )

      challenge = SecureRandom.hex
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :unauthorized

      assert_equal I18n.translate("devise.failure.webauthn_challenge_verification_error"), response.parsed_body["error"]
      assert_nil expected_stored_reauthentication_token
      assert_nil get_session_challenge
      assert_resource_not_signed_in
    end

    test """reauthenticate:
      - raises an error if the credential is invalid
      - clears the challenge session variable
      - does not have a reauthentication_token in the session
    """ do
      sign_in_as_resource
      assert_new_challenge_authorized do
        issue_new_challenge_action
      end
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: expected_credentials_to_allow
      )

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      invalidate_all_credentials

      assert_reauthentication_authorized do
        reauthenticate_action(params: {passkey_credential: credential.to_json})
      end
      assert_response :unauthorized

      assert_equal I18n.translate("devise.failure.stored_credential_not_found"), response.parsed_body["error"]
      assert_nil expected_stored_reauthentication_token
      assert_nil get_session_challenge
      assert_resource_not_signed_in
    end
  end
end