# frozen_string_literal: true

class Practical::Views::Form::FieldsetTitleComponent < Practical::Views::BaseComponent
  attr_accessor :options
  renders_one :icon

  def initialize(options: {})
    self.options = options
  end

  def call
    tag.span(**mix({}, options)) {
      safe_join([
        (icon if icon?),
        " ",
        tag.span{ content }
      ])
    }
  end
end
