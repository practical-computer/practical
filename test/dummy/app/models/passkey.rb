# frozen_string_literal: true

class Passkey < ApplicationRecord
  belongs_to :user
  has_one :emergency_passkey_registration, dependent: :destroy

  validates :label, presence: true, allow_blank: false, uniqueness: {scope: :user_id}
  validates :external_id, presence: true, allow_blank: false, uniqueness: true
  validates :public_key, presence: true, allow_blank: false, uniqueness: true
end
