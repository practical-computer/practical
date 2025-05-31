# frozen_string_literal: true

require "test_helper"

class Organization::MembershipFormTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Memberships::Forms::Organization::Membership

  def form_class
    Organization::MembershipForm
  end
end