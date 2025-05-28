# frozen_string_literal: true

require "webauthn/fake_client"

module Practical::Test::Helpers::Passkey::System::Base
  def fake_authenticator
    @fake_authenticator ||= WebAuthn::FakeAuthenticator.new
  end

  def user_webauthn_client
    @webauthn_client ||= WebAuthn::FakeClient.new(relying_party_origin, authenticator: fake_authenticator)
  end

  def administrator_webauthn_client
    @webauthn_client ||= WebAuthn::FakeClient.new(admin_relying_party_origin, authenticator: fake_authenticator)
  end

  def user_relying_party
    return WebAuthn::RelyingParty.new(
      allowed_origins: relying_party_origin,
      name: I18n.translate("app_title.text")
    )
  end

  def create_webauthn_credential_from_scratch(webauthn_client:, rp_id: nil, relying_party:)
    rp_id ||= relying_party.id || URI.parse(webauthn_client.origin).host

    create_result = webauthn_client.create(rp_id: rp_id)

    attestation_object =
      if webauthn_client.encoding
        relying_party.encoder.decode(create_result["response"]["attestationObject"])
      else
        create_result["response"]["attestationObject"]
      end

    client_data_json =
      if webauthn_client.encoding
        relying_party.encoder.decode(create_result["response"]["clientDataJSON"])
      else
        create_result["response"]["clientDataJSON"]
      end

    response = WebAuthn::AuthenticatorAttestationResponse.new(
      attestation_object: attestation_object,
      client_data_json: client_data_json,
      relying_party: relying_party
    )

    return response.credential
  end
end