# frozen_string_literal: true

module Practical::Auth::Passkeys::Controllers::WebAuthnDebugContext
  def honeybadger_webauthn_context
    debug_credential = WebAuthn::Credential.from_create(parsed_credential, relying_party: relying_party)
    debug_client_data_json = debug_credential.response.client_data.as_json

    return {
      debug_client_data_json: debug_client_data_json,
      relying_party_json: relying_party.as_json
    }
  end
end