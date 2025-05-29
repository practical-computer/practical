# frozen_string_literal: true

module Practical::Auth::Passkeys::EmergencyRegistrations
  extend ActiveSupport::Concern
  include Practical::Auth::Passkeys::WebAuthnDebugContext

  def new_challenge
    options_for_registration = generate_registration_options(
      relying_party: relying_party,
      user_details: user_details_for_registration,
      exclude: exclude_external_ids_for_registration
    )

    store_challenge_in_session(options_for_registration: options_for_registration)

    render json: options_for_registration
  end

  def raw_credential
    passkey_params[:passkey_credential]
  end

  def verify_credential_integrity
    return render_credential_missing_or_could_not_be_parsed_error if parsed_credential.nil?
    return render_credential_missing_or_could_not_be_parsed_error unless parsed_credential.kind_of?(Hash)
  rescue JSON::JSONError, TypeError
    return render_credential_missing_or_could_not_be_parsed_error
  end

  def verify_passkey_challenge
    @webauthn_credential = verify_registration(relying_party: relying_party)
  rescue ::WebAuthn::Error => e
    Honeybadger.notify(e, context: honeybadger_webauthn_context)
    error_key = Warden::WebAuthn::ErrorKeyFinder.webauthn_error_key(exception: e)
    render_passkey_error(message: find_message(error_key))
    return false
  end

  def request_form_params
    params.require(:new_emergency_passkey_registration_form).permit(:email)
  end

  def render_credential_missing_or_could_not_be_parsed_error
    render_passkey_error(message: find_message(:credential_missing_or_could_not_be_parsed))
    delete_registration_challenge
    return false
  end

  def render_passkey_error(message:)
    errors = Practical::Views::ErrorHandling.build_error_json(
      model: temporary_form_with_passkey_credential_error(message: message),
      helpers: helpers
    )

    render json: errors, status: :unprocessable_entity
  end
end