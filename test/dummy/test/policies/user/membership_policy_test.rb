# frozen_string_literal: true

require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class User::MembershipPolicyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Memberships::Policies::User::Membership

  def policy_for(membership:, user:)
    User::MembershipPolicy.new(membership, user: user)
  end
end