# frozen_string_literal: true

class MembershipInvitation < ApplicationRecord
  class AlreadyUsedError < StandardError; end

  enum :membership_type, Membership.membership_types

  belongs_to :organization
  belongs_to :sender, class_name: "User"
  belongs_to :membership, optional: true
  belongs_to :user, optional: true

  normalizes :email, with: ->(email){ email.strip.downcase }

  validates :email, presence: true, allow_blank: false, uniqueness: {scope: :organization_id}
  validates :membership_type, presence: true, allow_blank: false
  validate :sender_has_membership_in_organization, on: :create

  scope :visible, -> { where(visible: true) }
  scope :unused, -> { where(user: nil) }

  generates_token_for :invitation do
    user_id
  end

  def use_for_and_notify!(user:)
    raise AlreadyUsedError if self.user.present?
    self.user = user
    self.membership = create_membership!
    self.save!
    MembershipInvitationMailer.invitation_accepted(membership_invitation: self).deliver_later
  end

  def create_membership!
    return organization.memberships.create!(
      state: :active,
      user: self.user,
      membership_type: self.membership_type
    )
  end

  def can_be_resent?
    return false if last_sent_at.present? && last_sent_at > 10.minutes.ago
    return false if user.present?
    return false if !visible?

    return true
  end

  protected

  def sender_has_membership_in_organization
    return if organization.blank?
    return if sender.blank?
    return if OrganizationPolicy.new(organization, user: sender).apply(:manage?)
    errors.add(:sender, :cannot_manage_organization)
  end
end
