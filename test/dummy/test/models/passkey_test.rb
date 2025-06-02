# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Auth::Passkeys::Models::Passkey::Base

  def model_class
    Passkey
  end

  def model_instance
    users.user_1.passkeys.first
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
end
