# frozen_string_literal: true

class OrganizationPolicy < ActionPolicy::Base
  default_rule :manage?

  relation_scope do |relation|
    relation.where(memberships: user.memberships.active)
  end

  def show?
    record.memberships.active.where(user: user).any?
  end

  def manage?
    record.memberships.organization_manager.active.where(user: user).any?
  end

  def remove_organization_manager?
    record.memberships.organization_manager.active.count > 1
  end
end