# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Practical::Helpers::TranslationHelper
  include Practical::Views::FlashHelpers
  include Practical::Views::JSONRedirection

  verify_authorized

  helper_method :has_current_organization?,
                :current_organization,
                :inferred_current_organization

  protected

  def has_current_organization?
    @current_organization.present?
  end

  def current_organization
    raise CurrentOrganizationNotLoaded if !has_current_organization?
    return @current_organization
  end

  def inferred_current_organization
    return nil unless user_signed_in?
    return current_organization if has_current_organization?

    available_organizations = authorized_scope(current_user.organizations, with: OrganizationPolicy)

    if available_organizations.size == 1
      return available_organizations.first
    else
      return nil
    end
  end

  def authorize_current_user
    authorize!(current_user, to: :show?, with: UserPolicy)
  end
end
