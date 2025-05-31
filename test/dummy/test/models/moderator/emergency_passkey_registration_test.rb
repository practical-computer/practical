# frozen_string_literal: true

require "test_helper"

class Moderator::EmergencyPasskeyRegistrationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Auth::Passkeys::Models::EmergencyRegistration::Base
  include Practical::Test::Shared::Auth::Passkeys::Models::EmergencyRegistration::UseForAndNotify

  def model_class
    Moderator::EmergencyPasskeyRegistration
  end

  def model_instance
    moderators.moderator_1.emergency_passkey_registrations.first
  end

  def model_instance_with_passkey
    moderator_passkeys.moderator_1_passkey_2.emergency_passkey_registration
  end

  def owner_reflection_name
    :moderator
  end

  def owner_instance
    moderators.moderator_1
  end

  def user_agent_class_name
    UserAgent.to_s
  end

  def user_agent_reflection_name
    :user_agent
  end

  def ip_address_class_name
    IPAddress.to_s
  end

  def ip_address_reflection_name
    :ip_address
  end

  def expiration_timespan
    1.day
  end

  def already_used_error_class
    Moderator::EmergencyPasskeyRegistration::AlreadyUsedError
  end

  def passkey_mailer_class
    PasskeyMailer
  end

  def create_passkey_instance
    owner_instance.passkeys.create!(
      label: SecureRandom.hex,
      external_id: SecureRandom.hex,
      public_key: SecureRandom.hex
    )
  end
end
