# frozen_string_literal: true

class Users::MembershipInvitationsController < Users::BaseController
  before_action :load_membership_invitation
  before_action :authorize_management
  before_action :authorize_membership_invitation_management

  def destroy
    @membership_invitation.destroy

    set_flash_alert
    redirect_to user_memberships_url
  end

  protected

  def set_flash_alert
    message = t('user_memberships.invitation_hidden_message',
                organization_name: @membership_invitation.organization.name
              )

    icon = helpers.icon_set.destroy_membership_invitation_icon

    flash[:alert] = flash_alert_with_icon(message: message, icon: icon)
  end

  def load_membership_invitation
    @membership_invitation = authorized_scope(current_user.membership_invitations,
                                              with: User::MembershipInvitationPolicy).find(params[:id]
                                            )
  end

  def authorize_management
    authorize!(current_user, to: :manage?, with: UserPolicy)
  end

  def authorize_membership_invitation_management
    authorize!(@membership_invitation, to: :manage?, with: User::MembershipInvitationPolicy)
  end
end