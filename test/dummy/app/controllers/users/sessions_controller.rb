# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable
  include Devise::Passkeys::Controllers::SessionsControllerConcern
  include RelyingParty

  skip_verify_authorized

  def create
    super do |user|
      remember_me(user)
    end
  end

  protected

  def set_relying_party_in_request_env
    request.env[relying_party_key] = relying_party
  end
end
