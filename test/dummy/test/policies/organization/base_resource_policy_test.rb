# frozen_string_literal: true

require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organization::BaseResourcePolicyTest < ActiveSupport::TestCase
  def self.policy_class
    Organization::BaseResourcePolicy
  end

  include Practical::Test::Shared::Memberships::Policies::Organization::BaseResource
end
