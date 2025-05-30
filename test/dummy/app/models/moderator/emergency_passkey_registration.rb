class Moderator::EmergencyPasskeyRegistration < ApplicationRecord
  belongs_to :moderator
  belongs_to :passkey, class_name: "Moderator::Passkey", foreign_key: "moderator_passkey_id", optional: true
  belongs_to :ip_address, optional: true
  belongs_to :user_agent, optional: true
end
