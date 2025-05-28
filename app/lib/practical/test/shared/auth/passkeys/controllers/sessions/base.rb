# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Sessions::Base
  extend ActiveSupport::Concern

  included do
    test "new: renders successfully" do
      get_new_session_url
      assert_response :ok
    end

    test "new_challenge: does not require the resource to be authenticated and sets the session variable that stores the new challenge" do
      get root_url
      assert_resource_not_signed_in
      issue_new_challenge_action
      assert_response :ok
      assert_equal get_session_challenge, response.parsed_body["challenge"]
    end

    test "new_challenge: overrides the session variable that stores the new challenge" do
      issue_new_challenge_action
      assert_response :ok

      old_session_challenge = get_session_challenge

      issue_new_challenge_action
      assert_response :ok

      assert_not_equal old_session_challenge, get_session_challenge
      assert_not_equal old_session_challenge, response.parsed_body["challenge"]
    end

    test """create:
      - logs the resource in
      - clears the challenge session variable
      - sets the remember cookie value
    """ do
      issue_new_challenge_action
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: []
      )

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      assert_nil remember_cookie_value

      authenticate_action(params: {resource_key => {passkey_credential: credential.to_json}})
      assert_redirected_to root_url

      assert_resource_signed_in
      assert_resource_remembered
      assert_nil get_session_challenge
    end

    test """create:
      - raises an error if the challenge does not match what is in the session
      - clears the challenge session variable
    """ do
      issue_new_challenge_action
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: []
      )

      challenge = SecureRandom.hex
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      authenticate_action(params: {resource_key => {passkey_credential: credential.to_json}})
      assert_response :unprocessable_entity

      assert_nil get_session_challenge
      assert_resource_not_signed_in
    end

    test """create:
      - raises an error if the credential is invalid
      - clears the challenge session variable
    """ do
      issue_new_challenge_action
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: []
      )

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      invalidate_all_credentials

      authenticate_action(params: {resource_key => {passkey_credential: credential.to_json}})
      assert_response :unprocessable_entity

      assert_nil get_session_challenge
      assert_resource_not_signed_in
    end
  end
end