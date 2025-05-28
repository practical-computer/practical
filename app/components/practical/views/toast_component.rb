# frozen_string_literal: true

class Practical::Views::ToastComponent < Practical::Views::BaseComponent
  include Practical::Views::Button::Styling
  attr_accessor :appearance, :color_variant, :size, :options

  renders_one :icon

  def initialize(appearance: nil, color_variant: nil, size: nil, options: {})
    @options = options
    initialize_style_utilities(appearance: appearance, color_variant: color_variant, size: size)
  end

  def finalized_callout_options
    mix({
      class: class_names("wa-callout", css_classes_from_style_utilities)
    }, options)
  end
end
