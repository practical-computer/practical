# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Models::Passkey::Base
  extend ActiveSupport::Concern

  included do
    test "belongs_to the owner of the passkey" do
      reflection = model_class.reflect_on_association(owner_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "requires an owner in order to be valid" do
      instance = model_instance
      instance.send(:"#{owner_reflection_name}=", nil)

      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(owner_reflection_name, :blank)

      instance.send(:"#{owner_reflection_name}=", owner_instance)
      instance.valid?

      assert_equal false, instance.errors.of_kind?(owner_reflection_name, :blank)
    end

    test "label: is required and cannot be blank" do
      instance = model_instance
      instance.label = "   "

      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:label, :blank)

      instance.label = Faker::Computer.stack

      instance.valid?
      assert_equal false, instance.errors.of_kind?(:label, :blank)
    end

    test "label: must be unique for an owner" do
      instance = model_instance

      assert_equal true, instance.valid?

      new_instance = instance.send(:"#{owner_reflection_name}").passkeys.build(label: instance.label)

      assert_equal false, new_instance.valid?
      assert_equal true, new_instance.errors.of_kind?(:label, :taken)

      new_instance = other_owner_instance.passkeys.build(label: instance.label)
      new_instance.valid?
      assert_equal false, new_instance.errors.of_kind?(:label, :taken)
    end

    test "external_id: is required and cannot be blank" do
      instance = model_instance
      instance.external_id = "   "

      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:external_id, :blank)

      instance.external_id = SecureRandom.hex

      instance.valid?
      assert_equal false, instance.errors.of_kind?(:external_id, :blank)
    end

    test "external_id: is unique" do
      instance = model_class.new(external_id: model_instance.external_id)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:external_id, :taken)

      instance.external_id = SecureRandom.hex
      instance.valid?

      assert_equal false, instance.errors.of_kind?(:external_id, :taken)
    end

    test "public_key: is required and cannot be blank" do
      instance = model_instance
      instance.public_key = "   "

      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:public_key, :blank)

      instance.public_key = SecureRandom.hex

      instance.valid?
      assert_equal false, instance.errors.of_kind?(:public_key, :blank)
    end

    test "public_key: is unique" do
      instance = model_class.new(public_key: model_instance.public_key)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:public_key, :taken)

      instance.public_key = SecureRandom.hex
      instance.valid?

      assert_equal false, instance.errors.of_kind?(:public_key, :taken)
    end
  end
end