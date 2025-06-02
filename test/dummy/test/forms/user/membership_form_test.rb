# frozen_string_literal: true

require "test_helper"

class User::MembershipFormTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Memberships::Forms::User::Membership

  def form_class
    User::MembershipForm
  end
end