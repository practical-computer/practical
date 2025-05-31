# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Policies::User::Membership
  extend ActiveSupport::Concern

  included do
    def assert_can_manage(membership:, user:)
      assert_equal true, policy_for(membership: membership, user: user).apply(:manage?)
    end

    def assert_cannot_manage(membership:, user:)
      assert_equal false, policy_for(membership: membership, user: user).apply(:manage?)
    end

    def assert_can_leave(membership:, user:)
      assert_equal true, policy_for(membership: membership, user: user).apply(:leave?)
    end

    def assert_cannot_leave(membership:, user:)
      assert_equal false, policy_for(membership: membership, user: user).apply(:leave?)
    end

    test "manage?: only true for the user's memberships" do
      staff_membership = users.works_at_org_1_and_2.memberships.first

      assert_can_manage(membership: staff_membership, user: users.works_at_org_1_and_2)
      assert_cannot_manage(membership: staff_membership, user: users.organization_1_owner)
      assert_cannot_manage(membership: staff_membership, user: users.organization_1_manager)
      assert_cannot_manage(membership: staff_membership, user: users.organization_2_owner)
      assert_cannot_manage(membership: staff_membership, user: users.organization_1_staff)
      assert_cannot_manage(membership: staff_membership, user: users.retired_staff)
      assert_cannot_manage(membership: staff_membership, user: users.archived_organization_1_manager)

      organization_manager_membership = users.organization_1_manager.memberships.first

      assert_can_manage(membership: organization_manager_membership, user: users.organization_1_manager)
      assert_cannot_manage(membership: organization_manager_membership, user: users.organization_1_owner)
      assert_cannot_manage(membership: organization_manager_membership, user: users.organization_2_owner)
      assert_cannot_manage(membership: organization_manager_membership, user: users.works_at_org_1_and_2)
      assert_cannot_manage(membership: organization_manager_membership, user: users.retired_staff)
      assert_cannot_manage(membership: organization_manager_membership, user: users.archived_organization_1_manager)
    end

    test "leave?: only true if the membership_type is not organization_manager && there are multiple organization_managers for the organization" do
      staff_membership = users.works_at_org_1_and_2.memberships.first

      assert_can_leave(membership: staff_membership, user: users.works_at_org_1_and_2)
      assert_cannot_leave(membership: staff_membership, user: users.organization_1_owner)
      assert_cannot_leave(membership: staff_membership, user: users.organization_1_manager)
      assert_cannot_leave(membership: staff_membership, user: users.organization_2_owner)
      assert_cannot_leave(membership: staff_membership, user: users.organization_1_staff)
      assert_cannot_leave(membership: staff_membership, user: users.retired_staff)
      assert_cannot_leave(membership: staff_membership, user: users.archived_organization_1_manager)

      organization_manager_membership = users.organization_1_manager.memberships.first

      assert_can_leave(membership: organization_manager_membership, user: users.organization_1_manager)
      assert_cannot_leave(membership: organization_manager_membership, user: users.organization_1_owner)
      assert_cannot_leave(membership: organization_manager_membership, user: users.organization_2_owner)
      assert_cannot_leave(membership: organization_manager_membership, user: users.works_at_org_1_and_2)
      assert_cannot_leave(membership: organization_manager_membership, user: users.retired_staff)
      assert_cannot_leave(membership: organization_manager_membership, user: users.archived_organization_1_manager)


      only_manager_membership = users.organization_2_owner.memberships.first

      assert_cannot_leave(membership: only_manager_membership, user: users.organization_1_manager)
      assert_cannot_leave(membership: only_manager_membership, user: users.organization_1_owner)
      assert_cannot_leave(membership: only_manager_membership, user: users.organization_2_owner)
      assert_cannot_leave(membership: only_manager_membership, user: users.works_at_org_1_and_2)
      assert_cannot_leave(membership: only_manager_membership, user: users.retired_staff)
      assert_cannot_leave(membership: only_manager_membership, user: users.archived_organization_1_manager)

      organization_1_staff_membership = users.organization_1_staff.memberships.first
      assert_can_leave(membership: organization_1_staff_membership, user: users.organization_1_staff)
    end
  end
end