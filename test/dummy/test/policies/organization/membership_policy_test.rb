# frozen_string_literal: true

require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organization::MembershipPolicyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Memberships::Policies::Organization::Membership
  include Practical::Test::Shared::Memberships::Policies::Organization::Resource::Inherits

  def policy_for(membership:, user:)
    Organization::MembershipPolicy.new(membership, user: user, organization: membership.organization)
  end

  def policy_class
    Organization::MembershipPolicy
  end

  def resource_policy_class
    Organization::BaseResourcePolicy
  end

  def organization_policy(organization, user:)
    OrganizationPolicy.new(organization, user: user)
  end

  def all_memberships_relation
    Membership.all
  end
end