# frozen_string_literal: true

require "test_helper"

class CreateNewUserWithMembershipInvitationFormTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Memberships::Forms::CreateNewUserWithMembershipInvitation

  def form_class
    CreateNewUserWithMembershipInvitationForm
  end

  def user_class
    User
  end

  def passkey_class
    Passkey
  end
end