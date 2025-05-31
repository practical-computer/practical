# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Policies::Organization
  extend ActiveSupport::Concern
  included do
    test "default scope: returns all the organizations the user has access to" do
      assert_equal_set(
        [organizations.organization_1],
        relation_policy(user: users.organization_1_owner)
      )

      assert_equal_set(
        [organizations.organization_1],
        relation_policy(user: users.organization_1_manager)
      )

      assert_equal_set(
        [organizations.organization_1, organizations.organization_2],
        relation_policy(user: users.works_at_org_1_and_2)
      )

      assert_equal_set(
        [organizations.organization_2],
        relation_policy(user: users.organization_2_owner)
      )

      assert_empty relation_policy(user: users.organization_1_staff)
      assert_empty relation_policy(user: users.retired_staff)
      assert_empty relation_policy(user: users.archived_organization_1_manager)
    end

    test "show?: only true when the user has an active membership" do
      organization = organizations.organization_1

      assert_equal true, policy(organization: organization, user: users.organization_1_owner).apply(:show?)
      assert_equal true, policy(organization: organization, user: users.organization_1_manager).apply(:show?)
      assert_equal true, policy(organization: organization, user: users.works_at_org_1_and_2).apply(:show?)

      assert_equal false, policy(organization: organization, user: users.retired_staff).apply(:show?)
      assert_equal false, policy(organization: organization, user: users.archived_organization_1_manager).apply(:show?)

      assert_equal false, policy(organization: organization, user: users.organization_1_staff).apply(:show?)
      assert_equal false, policy(organization: organization, user: users.organization_2_owner).apply(:show?)
    end

    test "manage?: only true when the user has an active organization_manager membership" do
      organization = organizations.organization_1

      assert_equal true, policy(organization: organization, user: users.organization_1_owner).apply(:manage?)
      assert_equal true, policy(organization: organization, user: users.organization_1_manager).apply(:manage?)

      assert_equal false, policy(organization: organization, user: users.works_at_org_1_and_2).apply(:manage?)
      assert_equal false, policy(organization: organization, user: users.retired_staff).apply(:manage?)
      assert_equal false, policy(organization: organization, user: users.archived_organization_1_manager).apply(:manage?)

      assert_equal false, policy(organization: organization, user: users.organization_1_staff).apply(:manage?)
      assert_equal false, policy(organization: organization, user: users.organization_2_owner).apply(:manage?)
    end

    test "remove_organization_manager?: only allowed if more than 1 organization_manager" do
      organization_1 = organizations.organization_1
      assert_equal true, policy_class.new(organization_1, user: users.organization_1_owner).apply(:remove_organization_manager?)
      assert_equal false, policy_class.new(organizations.organization_2, user: users.organization_2_owner).apply(:remove_organization_manager?)

      organization_1.memberships.where(user: users.organization_1_manager).delete_all

      assert_equal false, policy_class.new(organization_1, user: users.organization_1_owner).apply(:remove_organization_manager?)
    end
  end
end