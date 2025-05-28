# frozen_string_literal: true

class Practical::Views::ButtonComponent < Practical::Views::BaseComponent
  include Practical::Views::Button::Styling
  attr_accessor :type, :appearance, :color_variant, :size, :options

  def initialize(type:, appearance: nil, color_variant: nil, size: nil, options: {})
    @type = type
    @options = options
    initialize_style_utilities(appearance: appearance, color_variant: color_variant, size: size)
  end

  def call
    defaults = {
      type: type,
      class: css_classes_from_style_utilities
    }

    if type.to_sym == :submit
      defaults[:data] = { disable: true }
    end

    finalized_options = mix(defaults, options)

    tag.button(content, **finalized_options)
  end
end
