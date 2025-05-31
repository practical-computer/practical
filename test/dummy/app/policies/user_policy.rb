class UserPolicy < ApplicationPolicy
  default_rule :manage?

  def manage?
    record == user
  end
end
