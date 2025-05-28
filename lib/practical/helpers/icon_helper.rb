# frozen_string_literal: true

module Practical::Helpers::IconHelper
  include Practical::Views::ElementHelper

  def icon_set
    ApplicationIconSet
  end

  def icon_text(icon:, text:, options: {})
    tag.span(**mix({class: "wa-flank wa-gap-xs icon-text"}, options)) {
      safe_join([
        (render icon),
        tag.span(text)
      ])
    }
  end
end
