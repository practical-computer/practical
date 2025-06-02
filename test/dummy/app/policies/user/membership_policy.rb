# frozen_string_literal: true

class User::MembershipPolicy < ApplicationPolicy
  default_rule :manage?

  def manage?
    (user.id == record.user_id)
  end

  relation_scope do |relation|
    if !allowed_to?(:show?, user, with: UserPolicy)
      next relation.none
    end

    relation.where(user: user).where.not(state: :archived_by_organization)
  end

  def leave?
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