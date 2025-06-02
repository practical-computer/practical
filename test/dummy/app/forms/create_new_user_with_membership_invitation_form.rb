# frozen_string_literal: true

class CreateNewUserWithMembershipInvitationForm
  include ActiveModel::API

  attr_accessor :user,
                :membership_invitation,
                :email,
                :name,
                :passkey_label,
                :webauthn_credential

  def initialize(attributes = {})
    super
    user.email = attributes[:email] if user.email.blank?
    user.name = attributes[:name] if user.name.blank?
  end

  def save!
    MembershipInvitation.transaction do
      user.save!
      user.passkeys.create!(
        label: passkey_label,
        public_key: webauthn_credential.public_key,
        external_id: Base64.strict_encode64(webauthn_credential.raw_id),
        sign_count: webauthn_credential.sign_count
      )

      membership_invitation.use_for_and_notify!(user: user)
    end
  rescue ActiveRecord::RecordInvalid => e
    label_errors = e.record.errors.where(:label)
    e.record.errors.delete(:label)
    self.errors.merge!(e.record.errors)
    label_errors.each{|error| self.errors.import(error, attribute: :passkey_label)}
    raise e
  end
end
