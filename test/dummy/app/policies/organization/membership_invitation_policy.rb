# frozen_string_literal: true

class Organization::MembershipInvitationPolicy < Organization::BaseResourcePolicy
  default_rule :manage?

  def manage?
    user.memberships
        .organization_manager
        .active
        .where(organization: record.organization)
        .any?
  end

  relation_scope do |relation|
    if !allowed_to?(:show?, organization, with: OrganizationPolicy)
      next relation.none
    end

    relation.unused.visible.where(organization: organization)
  end
end