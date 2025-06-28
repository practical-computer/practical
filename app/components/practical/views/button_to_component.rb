# frozen_string_literal: true

class Practical::Views::ButtonToComponent < Practical::Views::BaseComponent
  include Practical::Views::Button::Styling
  attr_accessor :url, :options, :appearance, :color_variant, :size, :html_options

  def initialize(url:, options:, appearance: nil, color_variant: nil, size: nil, html_options: {})
    self.url = url
    self.options = options
    self.html_options = html_options
    initialize_style_utilities(appearance: appearance, color_variant: color_variant, size: size)
  end

  def call
    html_option_defaults = {
      class: css_classes_from_style_utilities,
      data: {disable: true}
    }

    finalized_html_options = mix(html_option_defaults, html_options)
    helpers.button_to(url, **options, **finalized_html_options) { content }
  end
end
