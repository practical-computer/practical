# frozen_string_literal: true

class Practical::Views::Navigation::NavigationLinkComponent < ApplicationComponent
  attr_accessor :href, :options, :selected

  renders_one :icon

  def initialize(href:, selected:, options: {})
    self.href = href
    self.options = options
    self.selected = selected
  end

  def flank_class
    return "wa-flank wa-gap-2xs" if icon?
  end

  def selected?
    return true if selected
    return nil
  end

  def finalized_options
    mix({
      href: href,
      class: helpers.class_names(flank_class, "navigation-link", "wa-accent"),
      data: {selected: selected?}
    }, options)
  end

  def call
    tag.a(**finalized_options) {
      safe_join([
        (icon if icon?),
        tag.span{ content }
      ])
    }
  end
end
