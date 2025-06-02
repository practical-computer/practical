# frozen_string_literal: true

class Organizations::MembershipsController < Organizations::BaseController
  before_action :load_membership_invitations, only: [:index]
  before_action :load_memberships, only: [:index]
  before_action :load_membership, only: [:edit, :update]
  before_action :authorize_management, except: [:index]
  before_action :authorize_membership_management, only: [:edit, :update]

  def index
    @invitation_form = Organization::NewMembershipInvitationForm.new
  end

  def create
    @invitation_form = Organization::NewMembershipInvitationForm.new(
      membership_invitation_params.merge(
        current_organization: current_organization,
        sender: current_user
      )
    )

    @invitation_form.save!

    set_flash_after_create

    respond_to do |format|
      format.html { redirect_to organization_memberships_url }
      format.json { json_redirect(location: organization_memberships_url)}
    end
  rescue ActiveRecord::RecordInvalid, ActiveModel::ValidationError
    respond_to do |format|
      render_json_error(format: format, model: @invitation_form)
      render_html_error(action: :index, format: format) do
        load_membership_invitations
        load_memberships
      end
    end
  end

  def edit
    @form = Organization::MembershipForm.new(current_user: current_user,
                                             current_organization: current_organization,
                                             membership: @membership
                                            )
  end

  def update
    @form = Organization::MembershipForm.new(update_membership_params.merge(current_user: current_user,
                                                                            current_organization: current_organization,
                                                                            membership: @membership
                                            ))

    @form.save!

    flash[:success] = flash_success_with_icon(message: t('organization_memberships.updated_message'))
    redirect_to edit_organization_membership_url(current_organization, @membership)
  rescue ActiveRecord::RecordInvalid, ActiveModel::ValidationError
    default_respond_to_model_validation_error(html_action: :edit, model: @form)
  end

  protected

  def set_flash_after_create
    if @invitation_form.existing_membership&.active?
      flash[:success] = flash_success_with_icon(message: t('organization_memberships.already_member_message'))
    elsif @invitation_form.existing_membership&.pending_reacceptance?
      flash[:notice] = flash_notice_with_icon(message: t('organization_memberships.awaiting_reacceptance_message'))
    else
      icon = helpers.icon_set.sent_email_icon

      message = t('organization_memberships.invitation_sent_message', email: @invitation_form.invitation.email)
      flash[:success] = flash_notice_with_icon(message: message, icon: icon)
    end
  end

  def load_membership_invitations
    @membership_invitations = authorized_scope(current_organization.membership_invitations.order(email: :asc),
                                               with: Organization::MembershipInvitationPolicy
                                              )
  end

  def load_memberships
    @memberships = authorized_scope(current_organization.memberships.includes(:user).order("users.name": :asc),
                                    with: Organization::MembershipPolicy
                                  )
  end

  def load_membership
    @membership = authorized_scope(current_organization.memberships,
                                   with: Organization::MembershipPolicy).find(params[:id]
                                  )
  end

  def membership_invitation_params
    params.require(:organization_new_membership_invitation_form).permit(:email, :membership_type)
  end

  def update_membership_params
    params.require(:organization_membership_form).permit(:membership_type, :state)
  end

  def authorize_management
    authorize!(@current_organization, to: :manage?, with: OrganizationPolicy)
  end

  def authorize_membership_management
    authorize!(@membership, to: :manage?, with: Organization::MembershipPolicy)
  end
end
