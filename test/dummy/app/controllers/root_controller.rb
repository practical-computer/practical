# frozen_string_literal: true

class RootController < ApplicationController
  before_action :authenticate_user!

  layout "main_application"

  def index
  end
end
