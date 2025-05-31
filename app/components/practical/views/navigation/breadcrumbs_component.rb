# frozen_string_literal: true

class Practical::Views::Navigation::BreadcrumbsComponent < Practical::Views::BaseComponent
  attr_accessor :breadcrumb_trail
  attr_accessor :options

  def initialize(breadcrumb_trail:, options: {})
    self.breadcrumb_trail = breadcrumb_trail
    self.options = options
  end

  def finalized_options
    mix({}, options)
  end

  def crumbs_for_truncation
    @crumbs_for_truncation ||= breadcrumb_trail.to_a
  end

  def truncate_middle?
    crumbs_for_truncation.size > 5
  end

  def truncate_start
    crumbs_for_truncation.first(1)
  end

  def truncate_end
    crumbs_for_truncation.last(2)
  end

  def truncated_items
    crumbs_for_truncation - truncate_start - truncate_end
  end

  def build_crumb(crumb:)
    href = crumb.current? ? nil : crumb.url
    render(Practical::Views::Navigation::BreadcrumbItemComponent.new(options: { href: href })) {
      crumb.name
    }
  end
end
