# frozen_string_literal: true

class OrganizationNameComponent < ApplicationComponent
  attr_accessor :organization, :options
  delegate :name, to: :organization

  def initialize(organization:, options: {})
    self.organization = organization
    self.options = options
  end

  def call
    tag.span(**mix({class: "wa-flank organization-name"}, options)) {
      safe_join([
        tag.wa_avatar(
          initials: helpers.initials(name: name),
          shape: :rounded,
          style: "--size: var(--wa-font-size-2xl)"
        ),
        tag.span(name)
      ])
    }
  end
end
