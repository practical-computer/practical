class Moderator::Passkey < ApplicationRecord
  belongs_to :moderator
  has_one :emergency_passkey_registration, class_name: "Moderator::EmergencyPasskeyRegistration", foreign_key: :moderator_passkey_id, dependent: :destroy

  validates :label, presence: true, allow_blank: false, uniqueness: {scope: :moderator_id}
  validates :external_id, presence: true, allow_blank: false, uniqueness: true
  validates :public_key, presence: true, allow_blank: false, uniqueness: true
end
