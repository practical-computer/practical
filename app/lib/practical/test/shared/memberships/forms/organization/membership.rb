# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Forms::Organization::Membership
  extend ActiveSupport::Concern

  included do
    test "raises a validation error if trying to archive the only organization_manager" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              state: :archived_by_organization
                                            )

      assert_raises ActiveModel::ValidationError do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:state, :cannot_be_archived)
      assert_equal true, membership.reload.active?
    end

    test "can archive an organization_manager" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      membership = users.organization_1_manager.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              state: :archived_by_organization
                                            )

      form.save!

      assert_equal true, membership.reload.archived_by_organization?
    end

    test "can change an archived_by_organization membership to pending_reacceptance" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      membership = users.retired_staff.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              state: :pending_reacceptance
                                            )

      form.save!

      assert_equal true, membership.reload.pending_reacceptance?
    end

    test "can change a pending_reacceptance membership to archived_by_organization" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      membership = users.organization_1_staff.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              state: :archived_by_organization
                                            )

      form.save!

      assert_equal true, membership.reload.archived_by_organization?
    end

    test "cannot change the membership_type for the only organization_manager" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              membership_type: :staff
                                            )

      assert_raises ActiveModel::ValidationError do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:membership_type, :cannot_be_downgraded)
      assert_equal true, membership.reload.active?
      assert_equal true, membership.reload.organization_manager?
    end

    test "can change the membership_type for an organization_manager" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      membership = users.organization_1_manager.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              membership_type: :staff
                                            )

      form.save!

      assert_equal true, membership.reload.active?
      assert_equal true, membership.reload.staff?
    end

    test "can change the membership_type for a staff member" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      membership = users.works_at_org_1_and_2.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              membership_type: :organization_manager
                                            )

      form.save!

      assert_equal true, membership.reload.active?
      assert_equal true, membership.reload.organization_manager?
    end

    test "can change the membership_type for an archived membership" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      membership = users.retired_staff.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              membership_type: :organization_manager
                                            )

      form.save!

      assert_equal true, membership.reload.archived_by_organization?
      assert_equal true, membership.reload.organization_manager?
    end

    test "can change the membership_type for a pending_reacceptance membership" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      membership = users.organization_1_staff.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                                              current_organization: organization,
                                              membership: membership,
                                              membership_type: :organization_manager
                                            )

      form.save!

      assert_equal true, membership.reload.pending_reacceptance?
      assert_equal true, membership.reload.organization_manager?
    end
  end
end