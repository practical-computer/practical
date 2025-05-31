# frozen_string_literal: true

class Membership < ApplicationRecord
  enum :state, {
    pending_reacceptance: 0,
    active: 1,
    archived_by_organization: 2,
    archived_by_user: 3
  }

  enum :membership_type, {
    organization_manager: 0,
    staff: 1
  }

  belongs_to :organization
  belongs_to :user

  validates :user, uniqueness: {scope: :organization_id}
end
