# frozen_string_literal: true

class Practical::Views::Form::ErrorListItemComponent < Practical::Views::BaseComponent
  attr_reader :error

  def initialize(error:)
    @error = error
  end

  def before_render
    error.options[:has_been_rendered] = true
  end

  def call
    tag.li(data: {"pf-error-type": error.type, "pf-error-visible": true}) {
      tag.span(error.message, data: { "pf-error-message": true })
    }
  end
end
