# frozen_string_literal: true

class Organization::Membership::ArchiveButtonToComponent < ApplicationComponent
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
          state: :archived_by_organization
        }
      },
      class: "wa-danger"
    ){
      icon_text(icon: icon_set.archive_membership_icon, text: t('organization_memberships.archive.button_title'))
    }
  end
end
