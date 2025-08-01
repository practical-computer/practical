# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Controllers::Organization::Membership
  extend ActiveSupport::Concern

  included do
    test "index: lists all non-archived-by_user membership types and membership invitations" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      sign_in(user)

      self_archived_user = users.archived_organization_1_manager
      self_archived_user.memberships.update!(state: :archived_by_user)

      active_membership_user = users.organization_1_manager
      pending_reacceptance_user = users.works_at_org_1_and_2
      archived_by_organization_user = users.retired_staff

      membership_invitation = organization.membership_invitations.create!(email: Faker::Internet.email, membership_type: :staff, sender: user)

      pending_reacceptance_user.memberships.find_by!(organization: organization).update!(state: :pending_reacceptance)

      assert_index_policies_applied(organization: organization) do
        get organization_memberships_url(organization)
      end

      assert_response :ok
      assert_index_markup(
        active_membership_user: active_membership_user,
        pending_reacceptance_user: pending_reacceptance_user,
        archived_by_organization_user: archived_by_organization_user,
        membership_invitation: membership_invitation,
        self_archived_user: self_archived_user
      )
    end

    test "create: creates a new invitation" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      email = Faker::Internet.email

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :staff
        }
      }

      assert_difference "MembershipInvitation.count", +1 do
      assert_no_difference "Membership.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end
      end

      assert_json_redirected_to(organization_memberships_url(organization))
      message = I18n.t('organization_memberships.invitation_sent_message', email: email)
      assert_flash_message(type: :success, message: message, icon_name: 'envelope-dot')
    end

    test "create: resends a pending invitation" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      email = users.invited_user_1.email
      previous_invitation = organization.membership_invitations.find_by!(email: email)
      previous_invitation.update!(last_sent_at: 1.hour.ago)

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :organization_manager
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end

      assert_json_redirected_to(organization_memberships_url(organization))
      message = I18n.t('organization_memberships.invitation_sent_message', email: email)
      assert_flash_message(type: :success, message: message, icon_name: 'envelope-dot')
    end

    test "create: marks a archived_by_organization invitation as pending_reacceptance" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      sign_in(user)

      email = users.organization_1_staff.email
      previous_membership = organization.memberships.includes(:user).find_by!(user: {email: email})
      assert_equal true, previous_membership.pending_reacceptance?

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :organization_manager
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end

      assert_json_redirected_to(organization_memberships_url(organization))
      assert_flash_message(type: :notice, message: I18n.t('organization_memberships.awaiting_reacceptance_message'), icon_name: 'circle-info')
    end

    test "create: does nothing & returns a flash message if given an email for an active membership" do
      user = users.organization_1_manager
      organization = organizations.organization_1
      sign_in(user)

      email = users.works_at_org_1_and_2.email
      previous_membership = organization.memberships.includes(:user).find_by!(user: {email: email})
      assert_equal true, previous_membership.active?

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :organization_manager
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end

      assert_json_redirected_to(organization_memberships_url(organization))
      assert_flash_message(type: :success, message: I18n.t('organization_memberships.already_member_message'), icon_name: 'circle-check')
    end

    test "create: renders errors as JSON if given an email for a membership archived_by_user" do
      user = users.organization_1_manager
      organization = organizations.organization_1
      sign_in(user)

      email = users.works_at_org_1_and_2.email
      previous_membership = organization.memberships.includes(:user).find_by!(user: {email: email})
      previous_membership.update!(state: :archived_by_user)

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :organization_manager
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end

      assert_response :unprocessable_content

      assert_error_json_contains(
        container_id: "organization_new_membership_invitation_form_base_errors",
        element_id: "organization_new_membership_invitation_form_base",
        message: I18n.t('activemodel.errors.models.organization/new_membership_invitation_form.attributes.base.cannot_be_resent'),
        type: "cannot_be_resent"
      )
    end

    test "create: renders errors as JSON if given an email for a non-visible invitation" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      email = users.invited_user_1.email
      previous_invitation = organization.membership_invitations.find_by!(email: email)
      previous_invitation.update!(visible: false)

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :organization_manager
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end

      assert_response :unprocessable_content

      assert_error_json_contains(
        container_id: "organization_new_membership_invitation_form_base_errors",
        element_id: "organization_new_membership_invitation_form_base",
        message: I18n.t('activemodel.errors.models.organization/new_membership_invitation_form.attributes.base.cannot_be_resent'),
        type: "cannot_be_resent"
      )
    end

    test "create: renders errors as JSON if given an email for an invitation that was just sent out" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      email = users.invited_user_1.email
      previous_invitation = organization.membership_invitations.find_by!(email: email)
      previous_invitation.update!(last_sent_at: Time.now.utc)

      params = {
        organization_new_membership_invitation_form: {
          email: email,
          membership_type: :organization_manager
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end

      assert_response :unprocessable_content

      assert_error_json_contains(
        container_id: "organization_new_membership_invitation_form_base_errors",
        element_id: "organization_new_membership_invitation_form_base",
        message: I18n.t('activemodel.errors.models.organization/new_membership_invitation_form.attributes.base.cannot_be_resent'),
        type: "cannot_be_resent"
      )
    end

    test "create: renders errors as JSON" do
      user = users.organization_1_manager
      organization = organizations.organization_1

      sign_in(user)

      params = {
        organization_new_membership_invitation_form: {
          email: "",
          membership_type: :staff
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params, as: :json
      end
      end
      assert_response :unprocessable_content

      assert_error_json_contains(
        container_id: "organization_new_membership_invitation_form_email_errors",
        element_id: "organization_new_membership_invitation_form_email",
        message: "can't be blank",
        type: "blank"
      )
    end

    test "create: renders errors as HTML" do
      user = users.organization_1_manager
      organization = organizations.organization_1

      sign_in(user)

      params = {
        organization_new_membership_invitation_form: {
          email: "",
          membership_type: :staff
        }
      }

      assert_no_difference "MembershipInvitation.count" do
      assert_create_policies_applied(organization: organization) do
        post organization_memberships_url(organization), params: params
      end
      end
      assert_response :unprocessable_content

      assert_error_dom(
        container_id: "organization_new_membership_invitation_form_email_errors",
        message: "can't be blank"
      )
    end

    test "edit: renders the form" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      sign_in(user)

      membership = users.organization_1_manager.memberships.find_by!(organization: organization)

      assert_edit_policies_applied(organization: organization, membership: membership) do
        get edit_organization_membership_url(organization, membership)
      end

      assert_response :ok

      css_select "form[action='#{organization_membership_url(organization, membership)}']"
    end

    test "update: can archive an active membership" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      sign_in(user)

      membership = users.organization_1_manager.memberships.find_by!(organization: organization)

      assert_update_policies_applied(organization: organization, membership: membership) do
        patch organization_membership_url(organization, membership), params: {organization_membership_form: {
          state: :archived_by_organization
        }}
      end

      assert_flash_message(type: :success, message: I18n.t('organization_memberships.updated_message'), icon_name: 'circle-check')
      assert_redirected_to edit_organization_membership_url(organization, membership)
      assert_equal true, membership.reload.archived_by_organization?
    end

    test "update: can archive a pending_reacceptance membership" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      sign_in(user)

      membership = users.organization_1_staff.memberships.find_by!(organization: organization)

      assert_update_policies_applied(organization: organization, membership: membership) do
        patch organization_membership_url(organization, membership), params: {organization_membership_form: {
          state: :archived_by_organization
        }}
      end

      assert_redirected_to edit_organization_membership_url(organization, membership)
      assert_equal true, membership.reload.archived_by_organization?
    end

    test "update: can unarchive an archived_by_organization membership" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      sign_in(user)

      membership = users.archived_organization_1_manager.memberships.find_by!(organization: organization)

      assert_update_policies_applied(organization: organization, membership: membership) do
        patch organization_membership_url(organization, membership), params: {organization_membership_form: {
          state: :pending_reacceptance
        }}
      end

      assert_flash_message(type: :success, message: I18n.t('organization_memberships.updated_message'), icon_name: 'circle-check')
      assert_redirected_to edit_organization_membership_url(organization, membership)
      assert_equal true, membership.reload.pending_reacceptance?
    end

    test "update: update the membership_type" do
      user = users.organization_1_owner
      organization = organizations.organization_1
      sign_in(user)

      membership = users.organization_1_manager.memberships.find_by!(organization: organization)

      assert_update_policies_applied(organization: organization, membership: membership) do
        patch organization_membership_url(organization, membership), params: {organization_membership_form: {
          membership_type: :staff
        }}
      end

      assert_redirected_to edit_organization_membership_url(organization, membership)
      assert_equal true, membership.reload.staff?
    end

    test "update: returns an error if trying to archive the only organization_manager" do
      user = users.organization_2_owner
      organization = organizations.organization_2
      sign_in(user)

      membership = user.memberships.find_by!(organization: organization)

      assert_update_policies_applied(organization: organization, membership: membership) do
        patch organization_membership_url(organization, membership), params: {organization_membership_form: {
          state: :archived_by_organization
        }}
      end

      assert_response :unprocessable_content

      assert_error_dom(
        container_id: "generic_errors_organization_membership_form",
        message: /This member cannot be archived/
      )

      assert_equal true, membership.reload.active?
    end
  end
end