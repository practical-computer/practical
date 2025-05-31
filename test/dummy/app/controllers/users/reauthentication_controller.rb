# frozen_string_literal: true

class Users::ReauthenticationController < DeviseController
  include Devise::Passkeys::Controllers::ReauthenticationControllerConcern
  include RelyingParty

  before_action :authorize_management

  protected

  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end

  def authorize_management
    authorize!(current_user, to: :manage?, with: UserPolicy)
  end
end
