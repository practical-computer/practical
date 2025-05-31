# frozen_string_literal: true

require "test_helper"

class Organization::NewMembershipInvitationFormTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Memberships::Forms::Organization::NewMembershipInvitation

  def form_class
    Organization::NewMembershipInvitationForm
  end

  def membership_invitation_class
    MembershipInvitation
  end

  def membership_class
    Membership
  end
end