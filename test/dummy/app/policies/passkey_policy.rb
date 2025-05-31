# frozen_string_literal: true

class PasskeyPolicy < ApplicationPolicy
  default_rule :manage?

  def manage?
    (user.id == record.user_id)
  end
end
