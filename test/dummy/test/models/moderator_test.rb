require "test_helper"

class ModeratorTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Models::NormalizedEmail
  include Practical::Test::Shared::Auth::Passkeys::Models::ResourceWithPasskeys

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

  test "email: required and cannot be blank" do
    instance = model_instance
    instance.email = ""
    assert_equal false, instance.valid?
    assert_equal true, instance.errors.of_kind?(:email, :blank)

    instance.email = Faker::Internet.email
    assert_equal true, instance.valid?
  end
end
