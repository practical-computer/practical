# frozen_string_literal: true

class MembershipInvitation::DetailsComponent < ApplicationComponent
  attr_accessor :membership_invitation

  def initialize(membership_invitation:)
    @membership_invitation = membership_invitation
  end

  def call
    tag.wa_card(with_footer: true, class: "card-footer") {
      safe_join([
        tag.section{ render OrganizationNameComponent.new(organization: membership_invitation.organization) },
        tag.footer(slot: :footer) {
          icon_text(
            icon: icon_set.membership_type_icon(membership_type: membership_invitation.membership_type),
            text: t("membership_types.#{membership_invitation.membership_type}.human")
          )
        }
      ])
    }
  end
end
