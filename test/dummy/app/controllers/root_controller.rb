# frozen_string_literal: true

class RootController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_current_user
  authorize :user, through: :current_user

  layout "main_application"

  def index
  end

  protected
end
