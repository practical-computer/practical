# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Sessions::CrossPollination
  extend ActiveSupport::Concern

  included do
    test "create: does not allow another resource to log in" do
      sign_in_as_other_resource

      issue_new_challenge_action
      assert_response :ok

      assert_passkey_authentication_challenge(
        data: response.parsed_body,
        stored_challenge: expected_stored_challenge,
        credentials_to_allow: []
      )

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      authenticate_action(params: {resource_key => {passkey_credential: credential.to_json}})
      assert_response :unprocessable_content

      assert_nil get_session_challenge
      assert_resource_not_signed_in
    end
  end
end