# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Models::EmergencyRegistration::Base
  extend ActiveSupport::Concern

  included do
    test "belongs_to the owner of the registration" do
      reflection = model_class.reflect_on_association(owner_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "requires an owner to be valid" do
      instance = model_instance
      instance.send(:"#{owner_reflection_name}=", nil)

      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(owner_reflection_name, :blank)

      instance.send(:"#{owner_reflection_name}=", owner_instance)
      instance.valid?

      assert_equal false, instance.errors.of_kind?(owner_reflection_name, :blank)
    end

    test "optionally belongs_to user_agent" do
      reflection = model_class.reflect_on_association(user_agent_reflection_name)
      assert_equal :belongs_to, reflection.macro
      assert_equal user_agent_class_name, reflection.class_name
      assert_equal true, reflection.options[:optional]
    end

    test "optionally belongs_to ip_address" do
      reflection = model_class.reflect_on_association(ip_address_reflection_name)
      assert_equal :belongs_to, reflection.macro
      assert_equal ip_address_class_name, reflection.class_name
      assert_equal true, reflection.options[:optional]
    end

    test "optionally belongs_to a passkey" do
      reflection = model_class.reflect_on_association(:passkey)
      assert_equal :belongs_to, reflection.macro
      assert_equal true, reflection.options[:optional]
    end

    test "when a passkey is destroyed, the emergency_registration is destroyed as well" do
      emergency_registration = model_instance_with_passkey
      passkey = emergency_registration.passkey

      passkey.destroy!

      assert_nil model_class.find_by(id: emergency_registration.id)
    end

    test "available: scope only returns instances where used_at is nil" do
      instance = model_instance
      assert_nil instance.used_at

      assert_includes model_class.available, instance

      instance.update!(used_at: Time.now.utc)

      assert_not_includes model_class.available, instance
    end

    test "generates_token_for emergency_registration that expires within the designated time" do
      instance = model_instance

      token = instance.generate_token_for(:emergency_registration)

      assert_equal instance, model_class.find_by_token_for(:emergency_registration, token)

      Timecop.freeze(Time.now.utc + expiration_timespan) do
        assert_nil model_class.find_by_token_for(:emergency_registration, token)
      end
    end

    test "generates_token_for emergency_registration that expires when used_at is set" do
      instance = model_instance

      token = instance.generate_token_for(:emergency_registration)

      assert_equal instance, model_class.find_by_token_for(:emergency_registration, token)

      instance.update!(used_at: Time.now.utc)

      assert_nil model_class.find_by_token_for(:emergency_registration, token)
    end
  end
end