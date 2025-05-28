# frozen_string_literal: true

require "webauthn/fake_client"

module Practical::Test::Helpers::Passkey::TestHelper
  def assert_passkey_registration_challenge(
    data:,
    stored_challenge:,
    relying_party_data:,
    user_data:,
    credentials_to_exclude: []
  )
    authentication_selection = {"residentKey"=>"required", "userVerification"=>"required"}

    assert_equal stored_challenge, data["challenge"]
    assert_equal relying_party_data, data["rp"]
    assert_equal user_data, data["user"]
    assert_equal authentication_selection, data["authenticatorSelection"]

    assert_equal credentials_to_exclude, data["excludeCredentials"]
  end

  def assert_passkey_authentication_challenge(
    data:,
    stored_challenge:,
    credentials_to_allow: []
  )
    assert_equal stored_challenge, data["challenge"]
    assert_equal "required", data["userVerification"]

    assert_equal credential_id_for_challenge(passkeys: credentials_to_allow), data["allowCredentials"]
  end

  def credential_id_for_challenge(passkeys:)
    Array.wrap(passkeys).map{|x| {"type" => "public-key", "id" => x.external_id} }
  end

  def administrator_user_data(administrator:)
    {"name"=>administrator.email, "id"=>administrator.webauthn_id, "displayName"=>administrator.email}
  end

  def user_data(user:)
    {"name"=>user.email, "id"=>user.webauthn_id, "displayName"=>user.name}
  end

  def credential_data_for_passkey(passkey:)
    {"type"=>"public-key", "id"=> passkey.external_id}
  end

  def relying_party_origin
    AppSettings.relying_party_origin
  end

  def admin_relying_party_origin
    AppSettings.admin_relying_party_origin
  end

  def admin_relying_party_id
    URI.parse(admin_relying_party_origin).host
  end

  def user_relying_party_id
    URI.parse(relying_party_origin).host
  end

  def admin_relying_party(options: {})
    return WebAuthn::RelyingParty.new(**{
      allowed_origins: admin_relying_party_origin,
      name: I18n.translate("administrator.app_title.text")
    }.merge(options))
  end

  def relying_party(options: {})
    return WebAuthn::RelyingParty.new(**{
      allowed_origins: relying_party_origin,
      name: I18n.translate("app_title.text")
    }.merge(options))
  end

  def fake_authenticator
    return WebAuthn::FakeAuthenticator.new
  end

  def fake_client(origin: "https://example.test", authenticator: WebAuthn::FakeAuthenticator.new)
    return WebAuthn::FakeClient.new(origin, authenticator: authenticator)
  end

  def encode_challenge(raw_challenge:)
    Base64.strict_encode64(raw_challenge)
  end

  def assertion_from_client(client:, challenge:, user_verified: true)
    client.get(challenge: challenge, user_verified: user_verified)
  end

  def hydrate_response_from_raw_credential(client:, relying_party:, raw_credential:)
    attestation_object = if client.encoding
      relying_party.encoder.decode(raw_credential["response"]["attestationObject"])
    else
      raw_credential["response"]["attestationObject"]
    end

  client_data_json =
    if client.encoding
      relying_party.encoder.decode(raw_credential["response"]["clientDataJSON"])
    else
      raw_credential["response"]["clientDataJSON"]
    end

  return WebAuthn::AuthenticatorAttestationResponse.new(
    attestation_object: attestation_object,
    client_data_json: client_data_json,
    relying_party: relying_party
  )
  end

  def create_credential_and_return_payload_from_challenge(client:, challenge:, user_verified: true)
    return client.create(challenge: challenge, user_verified: user_verified)
  end

  def get_credential_payload_from_challenge(client:, challenge:, user_verified: true)
    client.get(challenge: challenge, user_verified: user_verified)
  end

  def encoded_public_key(credential:, relying_party:)
    relying_party.encoder.encode(credential.public_key)
  end
end