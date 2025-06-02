# frozen_string_literal: true

require "test_helper"

class Organizations::MembershipsControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Shared::Memberships::Controllers::Organization::Membership

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
