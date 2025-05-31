# frozen_string_literal: true

class Organization::MembershipForm
  include ActiveModel::API
  include ActionPolicy::Behaviour

  authorize :user, through: :current_user
  authorize :organization, through: :current_organization

  attr_accessor :current_user, :current_organization, :membership, :membership_type, :state

  validate :can_be_archived?
  validate :can_downgrade_membership_type?

  def initialize(attributes = {})
    super(attributes)

    self.membership_type ||= membership.membership_type
    self.state ||= membership.state
  end

  def save!
    validate!

    membership.update!(
      membership_type: self.membership_type,
      state: self.state
    )
  end

  def can_be_archived?
    return if self.state == membership.state
    return unless state.to_sym == :archived_by_organization
    return if allowed_to?(:archive?, membership, with: Organization::MembershipPolicy)

    errors.add(:state, :cannot_be_archived)
  end

  def can_downgrade_membership_type?
    return if self.membership_type == membership.membership_type
    return unless membership_type.to_sym == :staff
    return if allowed_to?(:downgrade_membership_type?, membership, with: Organization::MembershipPolicy)

    errors.add(:membership_type, :cannot_be_downgraded)
  end
end