require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class UserPolicyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Policies::User::Base

  def policy_class
    UserPolicy
  end
end
