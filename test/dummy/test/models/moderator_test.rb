# frozen_string_literal: true

require "test_helper"

class ModeratorTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Models::NormalizedEmail
  include Practical::Test::Shared::Auth::Passkeys::Models::ResourceWithPasskeys::Base
  include Practical::Test::Shared::Auth::Passkeys::Models::ResourceWithPasskeys::EmergencyRegistration

  def model_class
    Moderator
  end

  def passkey_class
    Moderator::Passkey
  end

  def model_instance
    moderators.moderator_1
  end

  def passkey_instance
    moderators.moderator_1.passkeys.first
  end

  def emergency_passkey_registration_class
    Moderator::EmergencyPasskeyRegistration
  end
end
