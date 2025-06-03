# frozen_string_literal: true

module Practical::Views::ThemeHelper
  def theme_attribute
    if user_signed_in?
      return current_user.theme
    else
      return "match-system"
    end
  rescue
    return "match-system"
  end
end