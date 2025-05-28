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
    tag.li(class: 'wa-flank', data: {"error-type": error.type}) {
      render(icon_set.error_list_icon) +
      tag.span(error.message)
    }
  end
end
