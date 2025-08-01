# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Controllers::User::Membership
  extend ActiveSupport::Concern

  included do
    test "index: lists all non-archived-by_organization membership types and membership invitations" do
      extra_organization = Organization.create!(name: Faker::Company.name)
      invitation_organization = Organization.create(name: Faker::Company.name)
      invitation_organization.memberships.create!(user: users.user_1, membership_type: :organization_manager, state: :active)

      user = users.works_at_org_1_and_2
      sign_in(user)

      self_archived_membership = user.memberships.find_by(organization: organizations.organization_1)
      self_archived_membership.update!(state: :archived_by_user)

      active_membership = user.memberships.find_by!(organization: organizations.organization_2)
      pending_reacceptance_membership = user.memberships.create!(organization: organizations.organization_3, membership_type: :staff, state: :pending_reacceptance)
      archived_by_organization_membership = user.memberships.create!(organization: extra_organization, membership_type: :staff, state: :archived_by_organization)

      membership_invitation = invitation_organization.membership_invitations.create!(email: user.email, membership_type: :staff, sender: users.user_1)

      assert_index_policies_applied(user: user) do
        get user_memberships_url
      end

      assert_response :ok
      assert_index_markup(
        active_membership: active_membership,
        pending_reacceptance_membership: pending_reacceptance_membership,
        self_archived_membership: self_archived_membership,
        membership_invitation: membership_invitation,
        archived_by_organization_membership: archived_by_organization_membership,
      )
    end

    test "update: can archive an active membership" do
      user = users.works_at_org_1_and_2
      sign_in(user)

      membership = user.memberships.find_by!(organization: organizations.organization_1)

      assert_update_policies_applied(user: user, membership: membership) do
        patch user_membership_url(membership), params: {user_membership_form: {
          state: :archived_by_user
        }}
      end

      assert_flash_message(type: :notice, message: I18n.t('user_memberships.archived_message'), icon_name: 'circle-info')
      assert_redirected_to user_memberships_url
      assert_equal true, membership.reload.archived_by_user?
    end

    test "update: can archive a pending_reacceptance membership" do
      user = users.organization_1_staff
      sign_in(user)

      membership = user.memberships.find_by!(organization: organizations.organization_2)

      assert_update_policies_applied(user: user, membership: membership) do
        patch user_membership_url(membership), params: {user_membership_form: {
          state: :archived_by_user
        }}
      end

      assert_flash_message(type: :notice, message: I18n.t('user_memberships.archived_message'), icon_name: 'circle-info')
      assert_redirected_to user_memberships_url
      assert_equal true, membership.reload.archived_by_user?
    end

    test "update: cannot unarchive an archived_by_organization membership" do
      user = users.retired_staff
      sign_in(user)

      membership = user.memberships.find_by!(organization: organizations.organization_1)

      assert_not_found_policies_applied(user: user) do
        patch user_membership_url(membership), params: {user_membership_form: {
          state: :pending_reacceptance
        }}
      end

      assert_response :not_found
    end

    test "update: cannot update the membership_type" do
      user = users.organization_1_owner
      sign_in(user)

      membership = user.memberships.find_by!(organization: organizations.organization_1)

      assert_update_policies_applied(user: user, membership: membership) do
        patch user_membership_url(membership), params: {user_membership_form: {
          membership_type: :staff
        }}
      end

      assert_redirected_to user_memberships_url
      assert_equal true, membership.reload.organization_manager?
    end

    test "update: returns an error if trying to leave the only organization_manager" do
      user = users.organization_2_owner
      sign_in(user)

      membership = user.memberships.find_by!(organization: organizations.organization_2)

      assert_update_policies_applied(user: user, membership: membership) do
        patch user_membership_url(membership), params: {user_membership_form: {
          state: :archived_by_organization
        }}
      end

      assert_flash_message(type: :alert, message: I18n.t('activemodel.errors.models.user/membership_form.attributes.state.inclusion'), icon_name: 'triangle-exclamation')
      assert_redirected_to user_memberships_url

      assert_equal true, membership.reload.active?
    end
  end
end