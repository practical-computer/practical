# frozen_string_literal: true

require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class User::MembershipInvitationPolicyTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Memberships::Policies::User::MembershipInvitation

  def policy_for(invitation:, user:)
    User::MembershipInvitationPolicy.new(invitation, user: user)
  end

  def find_membership_invitation!(email:)
    MembershipInvitation.find_by!(email: email)
  end
end
