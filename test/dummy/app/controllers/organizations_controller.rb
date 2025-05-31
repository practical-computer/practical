class OrganizationsController < Users::BaseController
  before_action :load_organizations
  before_action :set_current_organization, only: [:show]

  def index
  end

  def show
  end

  def load_organizations
    @organizations = authorized_scope(current_user.organizations.order(name: :asc), with: OrganizationPolicy)
  end

  def set_current_organization
    @current_organization = current_user.organizations.find(params[:id])
    authorize!(@current_organization, to: :show?, with: OrganizationPolicy)
  end
end
