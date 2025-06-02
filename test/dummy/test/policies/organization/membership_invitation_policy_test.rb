# frozen_string_literal: true

require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organization::MembershipInvitationPolicyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Memberships::Policies::Organization::MembershipInvitation
  include Practical::Test::Shared::Memberships::Policies::Organization::Resource::Inherits

  def policy_class
    Organization::MembershipInvitationPolicy
  end

  def resource_policy_class
    Organization::BaseResourcePolicy
  end

  def policy_for(invitation:, user:)
    Organization::MembershipInvitationPolicy.new(invitation, organization: invitation.organization, user: user)
  end

  def relation_policy_for(organization:, user:)
    Organization::MembershipInvitationPolicy.new(nil, organization: organization, user: user)
  end

  def all_membership_invitations_relation
    MembershipInvitation.all
  end
end