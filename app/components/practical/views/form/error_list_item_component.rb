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
    tag.li(class: 'wa-flank', data: {"pf-error-type": error.type, "pf-error-visible": true}) {
      render(icon_set.error_list_icon) +
      tag.span(error.message, "data": { "pf-error-message": true })
    }
  end
end
