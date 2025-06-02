# frozen_string_literal: true

class Organization::Membership::ActivateButtonToComponent < ApplicationComponent
  attr_accessor :membership
  delegate :current_organization, to: :helpers

  def initialize(membership:)
    @membership = membership
  end

  def call
    helpers.button_to(
      organization_membership_url(current_organization, membership),
      method: :patch,
      params: {
        organization_membership_form: {
          state: :active
        }
      },
      class: "wa-success"
    ){
      icon_text(icon: icon_set.badge_icon, text: t('organization_memberships.activate.button_title'))
    }
  end
end
