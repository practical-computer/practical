# frozen_string_literal: true

class User::MembershipInvitationPolicy < ApplicationPolicy
  default_rule :manage?

  def manage?
    (user.email == record.email) &&
    record.user_id.nil? &&
    record.membership_id.nil? &&
    record.visible?
  end

  relation_scope do |relation|
    MembershipInvitation.unused.visible.where(email: user.email)
  end
end