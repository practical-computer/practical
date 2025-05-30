# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include Devise::Passkeys::Controllers::RegistrationsControllerConcern
  include RelyingParty

  before_action :configure_permitted_parameters
  prepend_before_action :check_if_self_service_registration_allowed, only: [:new_challenge, :new, :create]
  prepend_before_action :check_if_self_service_destruction_allowed, only: [:destroy]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  def update
    super do |resource|
      if resource.persisted? && resource.valid?
        redirect_url = edit_user_registration_url

        respond_to do |format|
          format.html { redirect_to redirect_url }
          format.json { json_redirect(location: redirect_url) }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json do
            errors = Practical::Views::ErrorHandling.build_error_json(model: resource, helpers: helpers)
            render json: errors, status: :unprocessable_entity
          end
        end
      end

      return
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email])
  end

  def check_if_self_service_registration_allowed
    return if Flipper.enabled?(:self_service_user_registration)
    head :not_implemented
    return
  end

  def check_if_self_service_destruction_allowed
    return if Flipper.enabled?(:self_service_user_destruction)
    head :not_implemented
    return
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
