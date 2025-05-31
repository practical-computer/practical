# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Registrations::Update
  extend ActiveSupport::Concern

  included do
    test "edit renders successfully for the resource" do
      sign_in_as_resource
      edit_registration_action
      assert_response :ok
    end

    test "edit does not render a different resource" do
      sign_in_as_resource
      attempt_to_edit_other_resource_action
      assert_response :ok
      assert_not_includes response.body, other_resource.email
    end

    test "update updates the resource after reauthentication" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

      new_reauthentication_challenge_action
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      reauthenticate_action(params: {passkey_credential: credential.to_json})
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      new_email = Faker::Internet.email

      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_updating_resource(email: new_email, reauthentication_token: reauthentication_token)

      assert_no_difference "#{resource_class}.count" do
        update_registration_action(params: params)
        assert_update_redirect
      end

      resource_instance.reload
      assert_equal new_email, resource_instance.email
    end

    test "update requires a reauthentication token" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

      new_reauthentication_challenge_action
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      reauthenticate_action(params: {passkey_credential: credential.to_json})
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      old_email = resource_instance.email
      new_email = Faker::Internet.email

      reauthentication_token = ""
      params = params_for_updating_resource(email: new_email, reauthentication_token: reauthentication_token)

      assert_no_difference "#{resource_class}.count" do
        update_registration_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      resource_instance.reload
      assert_equal old_email, resource_instance.email
    end

    test "update requires the reauthentication token to match the stored value" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

      new_reauthentication_challenge_action
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      reauthenticate_action(params: {passkey_credential: credential.to_json})
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      old_email = resource_instance.email
      new_email = Faker::Internet.email

      reauthentication_token = SecureRandom.hex
      params = params_for_updating_resource(email: new_email, reauthentication_token: reauthentication_token)

      assert_no_difference "#{resource_class}.count" do
        update_registration_action(params: params)
        assert_response :bad_request
        assert_not_reauthenticated_message
      end

      resource_instance.reload
      assert_equal old_email, resource_instance.email
    end

    test "update renders an error if the email is missing" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

      new_reauthentication_challenge_action
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      reauthenticate_action(params: {passkey_credential: credential.to_json})
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      old_email = resource_instance.email
      new_email = "  "

      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_updating_resource(email: new_email, reauthentication_token: reauthentication_token)

      assert_no_difference "#{resource_class}.count" do
        update_registration_action(params: params)
        assert_response :unprocessable_entity
        assert_form_error_for_blank_email
      end

      resource_instance.reload
      assert_equal old_email, resource_instance.email
    end

    test "update renders an error if the email is a duplicate" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

      new_reauthentication_challenge_action
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      reauthenticate_action(params: {passkey_credential: credential.to_json})
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      old_email = resource_instance.email
      new_email = other_resource.email

      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_for_updating_resource(email: new_email, reauthentication_token: reauthentication_token)

      assert_no_difference "#{resource_class}.count" do
        update_registration_action(params: params)
        assert_response :unprocessable_entity
        assert_form_error_for_taken_email
      end

      resource_instance.reload
      assert_equal old_email, resource_instance.email
    end

    test "update ignores when trying to update a different resource" do
      sign_in_as_resource

      client = webauthn_client
      create_passkey_for_user_and_return_webauthn_credential(user: resource_instance)

      new_reauthentication_challenge_action
      assert_response :ok
      assert_reauthentication_token_challenge

      challenge = response.parsed_body["challenge"]
      credential = get_credential_payload_from_challenge(client: client, challenge: challenge)

      reauthenticate_action(params: {passkey_credential: credential.to_json})
      assert_response :ok
      assert_equal expected_stored_reauthentication_token, response.parsed_body["reauthentication_token"]
      assert_nil expected_stored_reauthentication_challenge

      new_email = Faker::Internet.email

      reauthentication_token = response.parsed_body["reauthentication_token"]
      params = params_trying_to_update_other_resource(email: new_email, reauthentication_token: reauthentication_token)

      assert_no_difference "#{resource_class}.count" do
        update_registration_action(params: params)
        assert_update_redirect
      end

      resource_instance.reload
      assert_equal new_email, resource_instance.email
    end
  end
end