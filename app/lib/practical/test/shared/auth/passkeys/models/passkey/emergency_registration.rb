# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Models::Passkey::EmergencyRegistration
  extend ActiveSupport::Concern

  included do
    test "has_one: emergency_passkey_registration, dependent: :destroy" do
      reflection = model_class.reflect_on_association(emergency_passkey_registration_reflection_name)
      assert_equal :has_one, reflection.macro
      assert_equal :destroy, reflection.options[:dependent]
    end

    test "can destroy a passkey if it has an emergency_passkey_registration" do
      instance = model_instance_with_emergency_registration

      assert_not_nil instance.emergency_passkey_registration

      assert_difference "#{model_class}.count", -1 do
        instance.destroy!
      end
    end
  end
end