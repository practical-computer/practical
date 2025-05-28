# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::Registrations::NoSelfDestroy
  extend ActiveSupport::Concern

  included do
    test "destroy action returns 501" do
      sign_in_as_resource
      destroy_registration_action
      assert_response :not_implemented
    end
  end
end