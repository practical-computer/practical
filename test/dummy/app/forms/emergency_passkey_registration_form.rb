# frozen_string_literal: true

class EmergencyPasskeyRegistrationForm
  include ActiveModel::API

  attr_accessor :emergency_registration,
                :passkey_label,
                :webauthn_credential

  validates :webauthn_credential, presence: true, allow_nil: false

  def save!
    emergency_registration.class.transaction do
      new_passkey = emergency_registration.user.passkeys.create!(
        label: passkey_label,
        public_key: webauthn_credential.public_key,
        external_id: Base64.strict_encode64(webauthn_credential.raw_id),
        sign_count: webauthn_credential.sign_count
      )

      emergency_registration.use_for_and_notify!(new_passkey: new_passkey)
    end
  rescue ActiveRecord::RecordInvalid => e
    label_errors = e.record.errors.where(:label)
    e.record.errors.delete(:label)
    self.errors.merge!(e.record.errors)
    label_errors.each{|error| self.errors.import(error, attribute: :passkey_label)}
    raise e
  end
end
