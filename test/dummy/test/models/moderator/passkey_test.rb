# frozen_string_literal: true

require "test_helper"

class Moderator::PasskeyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Auth::Passkeys::Models::Passkey::Base

  def model_class
    Moderator::Passkey
  end

  def model_instance
    moderators.moderator_1.passkeys.first
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
end
