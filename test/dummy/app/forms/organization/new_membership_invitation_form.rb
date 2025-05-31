# frozen_string_literal: true

class Organization::NewMembershipInvitationForm
  include ActiveModel::API

  attr_accessor :current_organization, :email, :sender, :membership_type, :invitation, :existing_membership

  validates :email, presence: true, allow_blank: false, allow_nil: false
  validates :current_organization, presence: true, allow_blank: false, allow_nil: false

  def save!
    validate!

    existing_membership_by_email = current_organization.memberships.includes(:user).find_by(user: {email: email})

    if existing_membership_by_email.present?
      self.existing_membership = existing_membership_by_email
      handle_existing_membership!
      return
    end

    handle_invitation!
  rescue ActiveRecord::RecordInvalid => e
    self.errors.merge!(e.record.errors)
    raise e
  end

  def handle_invitation!
    existing_invitation = current_organization.membership_invitations.find_by(email: email)

    if existing_invitation.present?
      handle_existing_invitation!(existing_invitation: existing_invitation)
    else
      send_new_invitation!
    end
  end

  def send_new_invitation!
    self.invitation = current_organization.membership_invitations.create!(email: email,
                                                                          sender: sender,
                                                                          membership_type: membership_type
                                                                        )
    MembershipInvitationMailer.invitation(membership_invitation: invitation).deliver_later
    self.invitation.update!(last_sent_at: Time.now.utc)
  end

  def handle_existing_invitation!(existing_invitation:)
    self.existing_membership = existing_invitation.membership

    if self.existing_membership.present?
      handle_existing_membership!
      self.invitation = existing_invitation
      return
    end

    if existing_invitation.can_be_resent?
      self.invitation = existing_invitation
      MembershipInvitationMailer.invitation(membership_invitation: invitation).deliver_later
      self.invitation.update!(last_sent_at: Time.now.utc)
    else
      errors.add(:base, :cannot_be_resent)
      raise_validation_error
    end
  end

  def handle_existing_membership!
    case self.existing_membership.state
    when "pending_reacceptance", "active"
      return nil
    when "archived_by_organization"
      self.existing_membership.update!(state: :pending_reacceptance)
    when "archived_by_user"
      errors.add(:base, :cannot_be_resent)
      raise_validation_error
    else
      raise ArgumentError
    end
  end
end