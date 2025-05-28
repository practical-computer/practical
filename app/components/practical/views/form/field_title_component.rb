# frozen_string_literal: true

class Practical::Views::Form::FieldTitleComponent < Practical::Views::BaseComponent
  attr_accessor :options
  renders_one :icon

  def initialize(options: {})
    self.options = options
  end

  def flank_class
    return "wa-flank" if icon?
  end

  def call
    tag.section(**mix({class: [flank_class, "field-title"]}, options)) {
      safe_join([
        (icon if icon?),
        tag.div{ content }
      ])
    }
  end
end
