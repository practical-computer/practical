# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :passkey_authenticatable, :registerable, :rememberable
  normalizes :email, with: ->(email){ email.strip.downcase }

  validates :webauthn_id, presence: true, allow_blank: false, uniqueness: true
  validates :email, presence: true, allow_blank: false, uniqueness: true
  validates :name, presence: true, allow_blank: false

  has_many :passkeys, dependent: :destroy
  has_many :emergency_passkey_registrations, dependent: :destroy
  has_many :memberships, class_name: "::Membership"
  has_many :organizations, through: :memberships
  has_many :membership_invitations

  enum :theme, { "match-system": 0, "light": 1, "dark": 2 }, default: :"match-system", suffix: "theme"

  def self.passkeys_class
    Passkey
  end

  def self.find_for_passkey(passkey)
    self.find_by(id: passkey.user.id)
  end

  def after_passkey_authentication(passkey:)
  end
end


Devise.add_module :passkey_authenticatable,
                  model: 'devise/passkeys/model',
                  route: {session: [nil, :new, :create, :destroy] },
                  controller: 'controller/sessions',
                  strategy: true
