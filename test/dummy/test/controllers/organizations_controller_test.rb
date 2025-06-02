# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  def assert_index_policies_applied(user:, &block)
    assert_authorized_to(:manage?, user, with: UserPolicy) do
      assert_have_authorized_scope(type: :active_record_relation, with: OrganizationPolicy, &block)
    end
  end

  def assert_show_policies_applied(user:, organization:, &block)
    assert_authorized_to(:manage?, user, with: UserPolicy) do
      assert_authorized_to(:show?, organization, with: OrganizationPolicy, &block)
    end
  end

  test "index: lists all active organizations for the user" do
    user = users.works_at_org_1_and_2
    sign_in(user)

    assert_index_policies_applied(user: user) do
      get organizations_url
    end

    assert_response :ok
    organizations = user.organizations.where(memberships: {state: :active})

    assert_not_empty organizations

    organizations.each do |organization|
      assert_dom "h2", text: organization.name
    end
  end

  test "show: renders the summary page for an organization" do
    user = users.works_at_org_1_and_2
    sign_in(user)

    organization = organizations.organization_2

    assert_show_policies_applied(user: user, organization: organization) do
      get organization_url(organization)
    end

    assert_response :ok
    assert_dom "h3", text: /Dashboard/
  end
end
