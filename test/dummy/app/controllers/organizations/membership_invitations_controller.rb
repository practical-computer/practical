# frozen_string_literal: true

class Organizations::MembershipInvitationsController < Organizations::BaseController
  before_action :load_membership_invitation
  before_action :authorize_management
  before_action :authorize_membership_invitation_management

  def resend
    if !@membership_invitation.can_be_resent?
      flash[:alert] = flash_alert_with_icon(message: t("organization_memberships.cannot_be_resent_message"))
      redirect_to organization_memberships_url
      return
    end

    @membership_invitation.update!(last_sent_at: Time.now.utc)
    MembershipInvitationMailer.invitation(membership_invitation: @membership_invitation).deliver_later

    set_invitation_flash_success
    redirect_to organization_memberships_url
  end

  def destroy
    @membership_invitation.destroy

    set_invitation_revoked_flash_alert
    redirect_to organization_memberships_url
  end

  protected

  def set_invitation_flash_success
    icon = helpers.icon_set.sent_email_icon

    message = t('organization_memberships.invitation_sent_message', email: @membership_invitation.email)
    flash[:success] = flash_notice_with_icon(message: message, icon: icon)
  end

  def set_invitation_revoked_flash_alert
    icon = helpers.icon_set.remove_link_icon

    message = t('organization_memberships.invitation_revoked_message', email: @membership_invitation.email)
    flash[:alert] = flash_alert_with_icon(message: message, icon: icon)
  end

  def load_membership_invitation
    @membership_invitation = authorized_scope(current_organization.membership_invitations,
                                              with: Organization::MembershipInvitationPolicy).find(params[:id]
                                            )
  end

  def authorize_management
    authorize!(@current_organization, to: :manage?, with: OrganizationPolicy)
  end

  def authorize_membership_invitation_management
    authorize!(@membership_invitation, to: :manage?, with: Organization::MembershipInvitationPolicy)
  end
end