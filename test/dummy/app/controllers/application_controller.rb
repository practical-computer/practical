# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Practical::Helpers::TranslationHelper
  include Practical::Views::FlashHelpers
  include Practical::Views::JSONRedirection

  verify_authorized

  protected

  def authorize_current_user
    authorize!(current_user, to: :show?, with: UserPolicy)
  end
end
