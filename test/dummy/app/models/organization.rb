# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :membership_invitations, dependent: :destroy
  has_many :memberships, dependent: :destroy, class_name: "::Membership"
  has_many :users, through: :memberships
end
