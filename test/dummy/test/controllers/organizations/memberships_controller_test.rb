# frozen_string_literal: true

require "test_helper"

class Organizations::MembershipsControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Shared::Memberships::Controllers::Organization::Membership

  def assert_index_markup(active_membership_user:, pending_reacceptance_user:, archived_by_organization_user:, membership_invitation:, self_archived_user:)
    assert_dom 'td', text: active_membership_user.name
    assert_dom 'td', text: pending_reacceptance_user.name
    assert_dom 'td', text: archived_by_organization_user.name
    assert_dom 'td', text: membership_invitation.email
    assert_dom 'td', text: self_archived_user.name, count: 0
  end

  def assert_create_policies_applied(organization:, &block)
    assert_authorized_to(:manage?, organization, with: OrganizationPolicy, &block)
  end

  def assert_index_policies_applied(organization:, &block)
    assert_have_authorized_scope(type: :active_record_relation, with: Organization::MembershipPolicy) do
      assert_have_authorized_scope(type: :active_record_relation, with: Organization::MembershipInvitationPolicy, &block)
    end
  end

  def assert_edit_policies_applied(organization:, membership:, &block)
    assert_authorized_to(:manage?, organization, with: OrganizationPolicy) do
      assert_authorized_to(:manage?, membership, with: Organization::MembershipPolicy, &block)
    end
  end

  def assert_update_policies_applied(organization:, membership:, &block)
    assert_authorized_to(:manage?, organization, with: OrganizationPolicy) do
      assert_authorized_to(:manage?, membership, with: Organization::MembershipPolicy, &block)
    end
  end
end
