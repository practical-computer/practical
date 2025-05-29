# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Practical::Helpers::TranslationHelper
  include Practical::Views::FlashHelpers
  include Practical::Views::JSONRedirection
end
