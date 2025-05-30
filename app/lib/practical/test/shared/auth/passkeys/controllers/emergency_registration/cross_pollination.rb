# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::EmergencyRegistration::CrossPollination
  extend ActiveSupport::Concern

  included do
    test "show: raises ActiveSupport::MessageVerifier::InvalidSignature if a different resource's Emergency Registration token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        show_emergency_registration_action(token: valid_emergency_registration_token_for_other_resource)
      end
    end

    test "new_create_challenge: raises ActiveSupport::MessageVerifier::InvalidSignature if a different resource's Emergency Registration token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        get_new_challenge_action(token: valid_emergency_registration_token_for_other_resource)
      end
    end

    test "use: raises ActiveSupport::MessageVerifier::InvalidSignature if a different resource's Emergency Registration token is given" do
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
      label = Faker::Computer.os

      params = params_for_using_emergency_passkey_registration(label: label, raw_credential: raw_credential)

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        use_emergency_registration_action(token: valid_emergency_registration_token_for_other_resource, params: params)
      end
    end
  end
end