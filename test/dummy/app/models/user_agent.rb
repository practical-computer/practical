# frozen_string_literal: true

class UserAgent < ApplicationRecord
  validates :user_agent, presence: true, allow_blank: false, uniqueness: true

  def self.upsert_user_agent(user_agent:)
    upsert({user_agent: user_agent}, returning: [:id], unique_by: :user_agent)
    find_by(user_agent: user_agent)
  end
end
