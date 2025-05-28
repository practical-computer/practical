# frozen_string_literal: true

class Practical::Views::Form::PracticalEditorComponent < Practical::Views::BaseComponent
  attr_accessor :input_id, :aria_describedby_id, :direct_upload_url, :options

  def initialize(input_id:, aria_describedby_id:, direct_upload_url:, options: {})
    self.input_id = input_id
    self.aria_describedby_id = aria_describedby_id
    self.direct_upload_url = direct_upload_url
    self.options = options
  end

  def finalized_options
    mix({
      input: input_id,
      serializer: :json,
      data: {direct_upload_url: direct_upload_url}
    }, options)
  end

  def call
    tag.practical_editor(**finalized_options) {
      tag.div("slot": :editor, "aria-describedby": aria_describedby_id)
    }
  end
end
