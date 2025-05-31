class Users::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_current_user
  authorize :user, through: :current_user

  layout "main_application"

  protected

  def authorize_current_user
    authorize!(current_user, to: :show?, with: UserPolicy)
  end
end
