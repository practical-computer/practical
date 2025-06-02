# frozen_string_literal: true

class Users::MembershipsController < Users::BaseController
  before_action :load_membership_invitations, only: [:index]
  before_action :load_memberships, only: [:index]
  before_action :load_membership, only: [:update]
  before_action :authorize_management, except: [:index]
  before_action :authorize_membership_management, only: [:update]

  def index
  end

  def update
    @form = User::MembershipForm.new(update_membership_params.merge(
      current_user: current_user,
      membership: @membership
    ))

    @form.save!
    message = message_for_update(membership: @form.membership)
    flash[:notice] = flash_notice_with_icon(message: message)
    redirect_to user_memberships_url
  rescue ActiveRecord::RecordInvalid, ActiveModel::ValidationError => e
    message = error_message_for_state(e: e)
    flash[:alert] = flash_alert_with_icon(message: message)
    redirect_to user_memberships_url
  end

  protected

  def message_for_update(membership:)
    if membership.archived_by_user?
      return t('user_memberships.archived_message')
    else
      returb t('user_memberships.updated_message')
    end
  end

  def error_message_for_state(e:)
    case e
    when ActiveRecord::RecordInvalid
      return e.record.errors.messages_for(:state).join(' ')
    when ActiveModel::ValidationError
      return e.model.errors.messages_for(:state).join(' ')
    end
  end

  def load_membership_invitations
    @membership_invitations = authorized_scope(MembershipInvitation.order(created_at: :asc),
                                               with: User::MembershipInvitationPolicy
                                              )
  end

  def load_memberships
    @memberships = authorized_scope(current_user.memberships.includes(:organization).order("organizations.name": :asc),
                                    with: User::MembershipPolicy
                                  )
  end

  def load_membership
    @membership = authorized_scope(current_user.memberships, with: User::MembershipPolicy).find(params[:id])
  end

  def update_membership_params
    params.require(:user_membership_form).permit(:state)
  end

  def authorize_management
    authorize!(current_user, to: :manage?, with: UserPolicy)
  end

  def authorize_membership_management
    authorize!(@membership, to: :manage?, with: User::MembershipPolicy)
  end
end