# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Controllers::Organization::MembershipInvitation
  extend ActiveSupport::Concern

  included do
    test "resend: resends a pending invitation and returns a flash message" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = organization.membership_invitations.find_by!(email: users.invited_user_1.email)
      time = Time.now.utc

      Timecop.freeze(time) do
      assert_policies_applied(organization: organization, membership_invitation: membership_invitation) do
      assert_no_difference "MembershipInvitation.count" do
        patch resend_organization_membership_invitation_url(organization, membership_invitation)
      end
      end
      end

      assert_redirected_to organization_memberships_url(organization)
      message = I18n.t('organization_memberships.invitation_sent_message', email: membership_invitation.email)
      assert_flash_message(type: :success, message: message, icon_name: 'envelope-dot')

      assert_enqueued_email_with(MembershipInvitationMailer, :invitation, args: [{membership_invitation: membership_invitation}])
      assert_equal time.to_fs(:db), membership_invitation.reload.last_sent_at.to_fs(:db)
    end

    test "resend: does nothing if the invitation cannot be resent yet" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = organization.membership_invitations.find_by!(email: users.invited_user_1.email)
      membership_invitation.update!(last_sent_at: Time.now.utc)
      old_last_sent_at = membership_invitation.last_sent_at

      assert_policies_applied(organization: organization, membership_invitation: membership_invitation) do
      assert_no_difference "MembershipInvitation.count" do
        patch resend_organization_membership_invitation_url(organization, membership_invitation)
      end
      end

      assert_redirected_to organization_memberships_url(organization)
      message = I18n.t("organization_memberships.cannot_be_resent_message")
      assert_flash_message(type: :alert, message: message, icon_name: 'triangle-exclamation')

      assert_no_enqueued_emails
      assert_equal old_last_sent_at.to_fs(:db), membership_invitation.reload.last_sent_at.to_fs(:db)
    end

    test "resend: returns 404 if the invitation is already tied to a user" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = users.invited_user_2.membership_invitations.find_by!(organization: organization)
      old_last_sent_at = membership_invitation.last_sent_at

      assert_policies_applied_on_404(organization: organization) do
      assert_no_difference "MembershipInvitation.count" do
        patch resend_organization_membership_invitation_url(organization, membership_invitation)
      end
      end

      assert_response :not_found
      assert_no_enqueued_emails
    end

    test "resend: does nothing if the invitation is not visible" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = organization.membership_invitations.find_by!(email: users.invited_user_1.email)
      membership_invitation.update!(visible: false)

      assert_policies_applied_on_404(organization: organization) do
      assert_no_difference "MembershipInvitation.count" do
        patch resend_organization_membership_invitation_url(organization, membership_invitation)
      end
      end

      assert_response :not_found

      assert_no_enqueued_emails
    end


    test "destroy: destroys a pending invitation and returns a flash message" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = organization.membership_invitations.find_by!(email: users.invited_user_1.email)

      assert_policies_applied(organization: organization, membership_invitation: membership_invitation) do
      assert_difference "MembershipInvitation.count", -1 do
        delete organization_membership_invitation_url(organization, membership_invitation)
      end
      end

      assert_redirected_to organization_memberships_url(organization)
      message = I18n.t('organization_memberships.invitation_revoked_message', email: membership_invitation.email)
      assert_flash_message(type: :alert, message: message, icon_name: 'link-slash')

      assert_no_enqueued_emails
    end

    test "destroy: returns 404 if the invitation is already tied to a user" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = users.invited_user_2.membership_invitations.find_by!(organization: organization)
      old_last_sent_at = membership_invitation.last_sent_at

      assert_policies_applied_on_404(organization: organization) do
      assert_no_difference "MembershipInvitation.count" do
        delete organization_membership_invitation_url(organization, membership_invitation)
      end
      end

      assert_response :not_found
      assert_no_enqueued_emails
    end

    test "destroy: returns 404 if the invitation is not visible" do
      user = users.organization_3_owner
      organization = organizations.organization_3
      sign_in(user)

      membership_invitation = organization.membership_invitations.find_by!(email: users.invited_user_1.email)
      membership_invitation.update!(visible: false)

      assert_policies_applied_on_404(organization: organization) do
      assert_no_difference "MembershipInvitation.count" do
        delete organization_membership_invitation_url(organization, membership_invitation)
      end
      end

      assert_response :not_found
      assert_no_enqueued_emails
    end
  end
end