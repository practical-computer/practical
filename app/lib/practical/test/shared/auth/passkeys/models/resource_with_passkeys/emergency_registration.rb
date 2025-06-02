# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Models::ResourceWithPasskeys::EmergencyRegistration
  extend ActiveSupport::Concern

  included do
    test "email: is required and cannot be blank" do
      instance = model_instance
      instance.email = ""
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:email, :blank)

      instance.email = Faker::Internet.email
      assert_equal true, instance.valid?
    end

    test "email: is unique" do
      instance = model_class.new(email: model_instance.email)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:email, :taken)

      instance.email = Faker::Internet.email
      instance.valid?

      assert_equal false, instance.errors.of_kind?(:email, :taken)
    end

    test "has many emergency_passkey_registrations" do
      reflection = model_class.reflect_on_association(:emergency_passkey_registrations)
      assert_equal :has_many, reflection.macro

      assert_difference "#{emergency_passkey_registration_class}.count", +1 do
        new_emergency_registration = model_instance.emergency_passkey_registrations.create!

        assert_instance_of emergency_passkey_registration_class, new_emergency_registration

        assert_includes model_instance.emergency_passkey_registrations, new_emergency_registration
      end
    end
  end
end