# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Forms::User::Membership
  extend ActiveSupport::Concern

  included do
    test "raises a validation error if trying to leave as the only organization_manager" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                            membership: membership,
                            state: :archived_by_user
                            )

      assert_raises ActiveModel::ValidationError do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:state, :cannot_be_archived)
      assert_equal true, membership.reload.active?
    end

    test "can archive an organization_manager" do
      user = users.organization_1_manager
      organization = organizations.organization_1
      membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                            membership: membership,
                            state: :archived_by_user
                          )

      form.save!

      assert_equal true, membership.reload.archived_by_user?
    end

    test "cannot change an archived_by_user membership" do
      user = users.retired_staff
      organization = organizations.organization_1
      membership = user.memberships.find_by!(organization: organization)
      membership.update!(state: :archived_by_user)

      form = form_class.new(current_user: user,
                            membership: membership,
                            state: :pending_reacceptance
                          )

      assert_raises ActiveModel::ValidationError do
        form.save!
      end

      assert_equal true, form.errors.of_kind?(:state, :inclusion)
      assert_equal true, membership.reload.archived_by_user?
    end

    test "can change a pending_reacceptance membership to archived_by_user" do
      user = users.organization_1_staff
      organization = organizations.organization_2
      membership = user.memberships.find_by!(organization: organization)

      form = form_class.new(current_user: user,
                            membership: membership,
                            state: :archived_by_user
                            )

      form.save!

      assert_equal true, membership.reload.archived_by_user?
    end

    test "cannot change the membership_type" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      membership = user.memberships.find_by!(organization: organization)

      assert_raises ActiveModel::UnknownAttributeError do
        form = form_class.new(current_user: user,
                              membership: membership,
                              membership_type: :staff
                              )
      end
    end
  end
end