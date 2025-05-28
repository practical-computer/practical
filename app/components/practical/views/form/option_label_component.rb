# frozen_string_literal: true

class Practical::Views::Form::OptionLabelComponent < Practical::Views::BaseComponent
  renders_one :title
  renders_one :description
  attr_accessor :options

  def initialize(options: {})
    self.options = options
  end


  def call
    tag.section(**mix({class: "wa-stack wa-size-s wa-gap-0"}, options)) {
      safe_join([
        tag.span(title),
        tag.small(description, class: "wa-quiet"),
      ])
    }
  end
end
