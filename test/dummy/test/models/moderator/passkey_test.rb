# frozen_string_literal: true

require "test_helper"

class Moderator::PasskeyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Auth::Passkeys::Models::Passkey::Base
  include Practical::Test::Shared::Auth::Passkeys::Models::Passkey::EmergencyRegistration

  def model_class
    Moderator::Passkey
  end

  def model_instance
    moderator_passkeys.moderator_1_passkey
  end

  def model_instance_with_emergency_registration
    moderator_passkeys.moderator_1_passkey_2
  end

  def owner_reflection_name
    :moderator
  end

  def owner_instance
    moderators.moderator_1
  end

  def other_owner_instance
    moderators.moderator_2
  end

  def emergency_passkey_registration_reflection_name
    :emergency_passkey_registration
  end

  def emergency_passkey_registration_class_name
    Moderator::EmergencyPasskeyRegistration
  end
end
