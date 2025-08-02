# frozen_string_literal: true

require "test_helper"

class Users::MembershipsControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Shared::Memberships::Controllers::User::Membership

  def assert_index_markup(active_membership:, pending_reacceptance_membership:, self_archived_membership:, membership_invitation:, archived_by_organization_membership:)
    assert_dom 'td', text: active_membership.organization.name
    assert_dom 'td', text: pending_reacceptance_membership.organization.name
    assert_dom 'td', text: self_archived_membership.organization.name
    assert_dom 'td', text: membership_invitation.organization.name
    assert_dom 'td', text: archived_by_organization_membership.organization.name, count: 0
  end

  def assert_index_policies_applied(user:, &block)
    assert_have_authorized_scope(type: :active_record_relation, with: User::MembershipPolicy) do
      assert_have_authorized_scope(type: :active_record_relation, with: User::MembershipInvitationPolicy, &block)
    end
  end

  def assert_update_policies_applied(user:, membership:, &block)
    assert_authorized_to(:manage?, user, with: UserPolicy) do
      assert_authorized_to(:manage?, membership, with: User::MembershipPolicy, &block)
    end
  end

  def assert_not_found_policies_applied(user:, &block)
    assert_have_authorized_scope(type: :active_record_relation, with: User::MembershipPolicy) do
      assert_authorized_to(:manage?, user, with: UserPolicy, &block)
    end
  end
end
