# frozen_string_literal: true

class User::MembershipForm
  include ActiveModel::API
  include ActionPolicy::Behaviour

  authorize :user, through: :current_user

  attr_accessor :current_user, :membership, :state

  validates :state, presence: true, allow_nil: false, inclusion: {in: [:archived_by_user, "archived_by_user"]}
  validate :can_be_archived?
  validate :state_can_be_changed?

  def save!
    validate!

    membership.update!(
      state: self.state
    )
  end

  def can_be_archived?
    return if errors.include?(:state)
    return if self.state == membership.state
    return unless state.to_sym == :archived_by_user
    return if allowed_to?(:leave?, membership, with: User::MembershipPolicy)

    errors.add(:state, :cannot_be_archived)
  end

  def state_can_be_changed?
    return if errors.include?(:state)
    return if self.state == membership.state
    return if membership.pending_reacceptance?
    return if membership.active?
    errors.add(:state, :cannot_be_changed)
  end
end