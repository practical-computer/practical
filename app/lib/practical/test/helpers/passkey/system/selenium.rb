# frozen_string_literal: true

require "webauthn/fake_client"

module Practical::Test::Helpers::Passkey::System::Selenium
  extend ActiveSupport::Concern
  include Practical::Test::Helpers::Passkey::System::Base

  included do
    teardown do
      if @virtual_authenticator.present? && @virtual_authenticator.valid?
        @virtual_authenticator.remove!
      end
    rescue Selenium::WebDriver::Error::InvalidArgumentError
    end

    def self.selenium_driver_key
      if ENV.has_key?("HEADLESS_TESTS")
        return :headless_chrome
      else
        return :chrome
      end
    end

    driven_by :selenium, using: selenium_driver_key, screen_size: [1400, 1400] do |options|
      options.accept_insecure_certs = true
      if ENV.has_key?("HEADLESS_TESTS")
        options.args << "--headless=new"
      end
    end
  end

  def create_passkey_for_user_and_return_webauthn_credential(user:)
    webauthn_credential = create_webauthn_credential_from_scratch(webauthn_client: user_webauthn_client,
                                                                  rp_id: user_relying_party_id,
                                                                  relying_party: user_relying_party
                                                                 )
    # rubocop:disable Layout/LineLength
    keypair = fake_authenticator.instance_variable_get("@credentials")[user_relying_party_id][webauthn_credential.id][:credential_key]
    # rubocop:enable Layout/LineLength

    resident_credential = create_credential(
      rp_id: user_relying_party_id,
      id: webauthn_credential.id.bytes,
      keypair: keypair
    )

    authenticator = add_virtual_authenticator
    authenticator.add_credential(resident_credential)

    user.passkeys.create!(
      label: SecureRandom.hex,
      external_id: Base64.strict_encode64(webauthn_credential.id),
      public_key: Base64.strict_encode64(webauthn_credential.public_key),
      sign_count: 0
    )

    return webauthn_credential
  end

  def authenticator_options(options: {})
    options = options.reverse_merge({
      protocol: :ctap2,
      resident_key: true,
      user_verification: true,
      user_verified: true
    })
    Selenium::WebDriver::VirtualAuthenticatorOptions.new(**options)
  end

  def add_virtual_authenticator(options: authenticator_options)
    @virtual_authenticator ||= Capybara.current_session.driver.browser.add_virtual_authenticator(options)
  end

  def default_authenticator
    @virtual_authenticator
  end

  def create_credential(rp_id:, user_handle: generate_user_handle, id:, keypair:)
    private_key = Base64.strict_encode64(keypair.private_to_der)
    decoded_private_key = Base64.strict_decode64(private_key).bytes

    return Selenium::WebDriver::Credential.resident(
      id: id,
      private_key: decoded_private_key,
      rp_id: rp_id,
      user_handle: user_handle
    )

    Selenium::WebDriver::Credential.resident(
      id: generate_credential_id,
      private_key: decoded_private_key,
      rp_id: "localhost",
      user_handle: generate_user_handle
    )

    keypair.public_key.to_bn.to_s(2)
    private_key = keypair.private_key.to_bn.to_s(2)
    return Selenium::WebDriver::Credential.resident(id: id.bytes,
                                                    private_key: private_key.bytes,
                                                    rp_id: rp_id,
                                                    user_handle: user_handle.bytes
                                                   )
  end

  def generate_user_handle
    SecureRandom.uuid.bytes
  end
end