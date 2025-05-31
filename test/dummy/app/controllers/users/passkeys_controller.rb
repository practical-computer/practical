# frozen_string_literal: true

class Users::PasskeysController  < DeviseController
  include Devise::Passkeys::Controllers::PasskeysControllerConcern
  include RelyingParty

  before_action :authorize_create, only: [:new_create_challenge, :create]
  before_action :authorize_destroy, only: [:new_destroy_challenge, :destroy]

  def create
    begin
      create_passkey(resource: resource) do |resource, passkey|
        if passkey.persisted?
          redirect_url = edit_user_registration_url
          respond_to do |format|
            format.html { redirect_to redirect_url }
            format.json { json_redirect(location: redirect_url) }
          end
          return
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      process_create_validation_errors(e: e)
      errors = Practical::Views::ErrorHandling.build_error_json(model: e.record, helpers: helpers)
      render json: errors, status: :unprocessable_entity
    end
  end

  def destroy
    @passkey.destroy
    redirect_url = edit_user_registration_url
    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.json { json_redirect(location: redirect_url) }
    end
  end

  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end

  def user_details_for_registration
    { id: resource.webauthn_id, name: resource.email, display_name: resource.name }
  end

  protected

  def process_create_validation_errors(e:)
    e.record.errors.each do |error|
      if error.options[:error_container_id].nil?
        error.options[:error_container_id] = helpers.field_id(:passkey, error.attribute, :errors)
      end

      if error.options[:element_id].nil?
        error.options[:element_id] = helpers.field_id(:passkey, error.attribute)
      end
    end
  end

  def authorize_create
    authorize!(current_user, to: :manage?, with: UserPolicy)
  end

  def authorize_destroy
    authorize!(@passkey, to: :manage?, with: PasskeyPolicy)
  end
end
