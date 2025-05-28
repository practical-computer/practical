require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class PasskeyPolicyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Auth::Passkeys::Policies::Passkey

  def policy_class
    PasskeyPolicy
  end

  def resource_with_passkeys
    users.user_1
  end

  def other_resource_with_passkeys
    users.user_2
  end
end
