# frozen_string_literal: true

class Practical::Views::OpenDrawerButtonComponent < Practical::Views::ButtonComponent
  attr_accessor :drawer_id

  def initialize(drawer_id:, appearance: nil, color_variant: nil, size: nil, options: {})
    options = options.with_defaults(
      onclick: self.class.inline_js_to_open_dialog(drawer_id: drawer_id)
    )
    super(type: :button, appearance: appearance, color_variant: color_variant, size: size, options: options)
  end

  def self.inline_js_to_open_dialog(drawer_id:)
    return "document.getElementById(`#{drawer_id}`).open = true"
  end
end
