# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Models::NormalizedEmail
  include Practical::Test::Shared::Models::User
  include Practical::Test::Shared::Auth::Passkeys::Models::ResourceWithPasskeys

  def model_class
    User
  end

  def passkey_class
    Passkey
  end

  def model_instance
    users.user_1
  end

  def passkey_instance
    users.user_1.passkeys.first
  end
end
