# frozen_string_literal: true

class Organizations::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_organization
  authorize :organization, through: :current_organization

  helper_method :current_organization

  protected

  def set_current_organization
    @current_organization = current_user.organizations.find(params[:organization_id])
    authorize!(@current_organization, to: :show?, with: OrganizationPolicy)
  end

  def current_organization
    raise ArgumentError if @current_organization.nil?
    @current_organization
  end
end