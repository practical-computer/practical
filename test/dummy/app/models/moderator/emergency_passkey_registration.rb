# frozen_string_literal: true

class Moderator::EmergencyPasskeyRegistration < ApplicationRecord
  class AlreadyUsedError < StandardError; end

  belongs_to :moderator
  belongs_to :passkey, class_name: "Moderator::Passkey", foreign_key: "moderator_passkey_id", optional: true
  belongs_to :ip_address, optional: true
  belongs_to :user_agent, optional: true

  scope :available, -> { where(used_at: nil) }

  generates_token_for :emergency_registration, expires_in: 15.minutes do
    used_at&.iso8601
  end

  def use_for_and_notify!(new_passkey:)
    raise AlreadyUsedError if self.passkey.present? || self.used_at.present?

    self.update!(
      used_at: Time.now.utc,
      passkey: new_passkey
    )

    PasskeyMailer.passkey_added(passkey: new_passkey).deliver_later
  end
end
