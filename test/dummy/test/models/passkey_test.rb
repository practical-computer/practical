# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Auth::Passkeys::Models::Passkey::Base
  include Practical::Test::Shared::Auth::Passkeys::Models::Passkey::EmergencyRegistration

  def model_class
    Passkey
  end

  def model_instance
    passkeys.user_1_passkey
  end

  def model_instance_with_emergency_registration
    passkeys.user_1_passkey_2
  end

  def owner_reflection_name
    :user
  end

  def owner_instance
    users.user_1
  end

  def other_owner_instance
    users.user_2
  end

  def emergency_passkey_registration_reflection_name
    :emergency_passkey_registration
  end

  def emergency_passkey_registration_class_name
    EmergencyPasskeyRegistration
  end
end
