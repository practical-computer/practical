module Practical::Memberships::Controllers::MembershipInvitations::RegisterWithPasskey
  extend ActiveSupport::Concern
  include Practical::Auth::Passkeys::Controllers::WebAuthnDebugContext

  def new_create_challenge
    options_for_registration = generate_registration_options(
      relying_party: relying_party,
      user_details: user_details_for_registration,
      exclude: []
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

  def honeybadger_webauthn_context
    debug_credential = WebAuthn::Credential.from_create(parsed_credential, relying_party: relying_party)
    debug_client_data_json = debug_credential.response.client_data.as_json

    return {
      debug_client_data_json: debug_client_data_json,
      relying_party_json: relying_party.as_json
    }
  end

  def request_form_params
    params.require(:create_new_user_with_membership_invitation_form).permit(:email)
  end

  def require_email_and_passkey_label
    if request_form_params[:email].blank?
      respond_to_email_missing_error
      return false
    end

    if passkey_params[:passkey_label].blank?
      respond_to_passkey_label_missing_error
      return false
    end

    true
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
    render json: errors, status: :bad_request
  end

  def registration_user_id
    session[registration_user_id_key]
  end

  def delete_registration_user_id!
    session.delete(registration_user_id_key)
  end

  def store_registration_user_id
    session[registration_user_id_key] = WebAuthn.generate_user_id
  end
end