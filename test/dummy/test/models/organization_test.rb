# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Memberships::Models::Organization::Base
  include Practical::Test::Shared::Attachment::Model::Organization::HasAttachments

  def model_class
    Organization
  end

  def membership_reflection_name
    :memberships
  end

  def membership_invitation_reflection_name
    :membership_invitations
  end

  def user_reflection_name
    :users
  end
end
