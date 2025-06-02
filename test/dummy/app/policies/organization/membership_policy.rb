# frozen_string_literal: true

class Organization::MembershipPolicy < Organization::BaseResourcePolicy
  default_rule :manage?
  alias_rule :downgrade_membership_type?, to: :archive?

  def manage?
    !record.archived_by_user? &&
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

    relation.where(organization: organization).where.not(state: :archived_by_user)
  end

  def archive?
    check?(:manage) &&
    (
      !record.organization_manager? ||
      (
        record.organization_manager? &&
        allowed_to?(:remove_organization_manager?, record.organization)
      )
    )
  end
end