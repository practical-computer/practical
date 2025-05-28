# frozen_string_literal: true

class Practical::Views::OpenDialogButtonComponent < Practical::Views::ButtonComponent
  attr_accessor :dialog_id

  def initialize(dialog_id:, appearance: nil, color_variant: nil, size: nil, options: {})
    options = options.with_defaults(
      onclick: self.class.inline_js_to_open_dialog(dialog_id: dialog_id)
    )
    super(type: :button, appearance: appearance, color_variant: color_variant, size: size, options: options)
  end

  def self.inline_js_to_open_dialog(dialog_id:)
    return "document.getElementById(`#{dialog_id}`).showModal()"
  end
end
