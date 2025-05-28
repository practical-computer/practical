# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Registrations::NoSelfSignup
  extend ActiveSupport::Concern

  included do
    test "new registration challenge action returns 501" do
      new_registration_challenge_action
      assert_response :not_implemented
    end

    test "new registration action returns 501" do
      new_registration_action
      assert_response :not_implemented
    end

    test "create registration action returns 501" do
      create_registration_action
      assert_response :not_implemented
    end
  end
end