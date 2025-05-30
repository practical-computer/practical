# frozen_string_literal: true

class Moderator < ApplicationRecord
  devise :passkey_authenticatable, :rememberable

  has_many :passkeys, class_name: "Moderator::Passkey", dependent: :destroy
  has_many :emergency_passkey_registrations, class_name: "Moderator::EmergencyPasskeyRegistration", dependent: :destroy

  normalizes :email, with: ->(email){ email.strip.downcase }
  validates :webauthn_id, presence: true, allow_blank: false, uniqueness: true
  validates :email, presence: true, allow_blank: false, uniqueness: true

  def self.passkeys_class
    Moderator::Passkey
  end

  def self.find_for_passkey(passkey)
    self.find_by(id: passkey.moderator.id)
  end

  def after_passkey_authentication(passkey:)
  end
end
