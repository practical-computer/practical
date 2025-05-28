# frozen_string_literal: true

require "webauthn/fake_client"

module Practical::Test::Helpers::Passkey::System::RackTest
  include Practical::Test::Helpers::Passkey::System::Base

  def create_passkey_for_user_and_return_webauthn_credential(user:)
    webauthn_credential = create_webauthn_credential_from_scratch(webauthn_client: user_webauthn_client,
                                                                  rp_id: user_relying_party_id,
                                                                  relying_party: user_relying_party
                                                                 )
    fake_authenticator.instance_variable_get("@credentials")[user_relying_party_id]
                                                            [webauthn_credential.id]
                                                            [:credential_key]

    user.passkeys.create!(
      label: SecureRandom.hex,
      external_id: Base64.strict_encode64(webauthn_credential.id),
      public_key: Base64.strict_encode64(webauthn_credential.public_key),
      sign_count: 0
    )

    return webauthn_credential
  end

  def create_passkey_for_administrator_and_return_webauthn_credential(administrator:)
    webauthn_credential = create_webauthn_credential_from_scratch(webauthn_client: administrator_webauthn_client,
                                                                  rp_id: admin_relying_party_id,
                                                                  relying_party: admin_relying_party
                                                                 )
    fake_authenticator.instance_variable_get("@credentials")[admin_relying_party_id]
                                                            [webauthn_credential.id]
                                                            [:credential_key]

    administrator.passkeys.create!(
      label: SecureRandom.hex,
      external_id: Base64.strict_encode64(webauthn_credential.id),
      public_key: Base64.strict_encode64(webauthn_credential.public_key),
      sign_count: 0
    )

    return webauthn_credential
  end
end