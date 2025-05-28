# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Models::ResourceWithPasskeys
  extend ActiveSupport::Concern

  included do
    test "has many passkeys" do
      reflection = model_class.reflect_on_association(:passkeys)
      assert_equal :has_many, reflection.macro

      assert_difference "#{passkey_class}.count", +1 do
        new_passkey = model_instance.passkeys.create!(
          label: SecureRandom.hex,
          external_id: SecureRandom.hex,
          public_key: SecureRandom.hex
        )

        assert_instance_of passkey_class, new_passkey

        assert_includes model_instance.passkeys, new_passkey
      end
    end

    test "passkeys_class" do
      assert_equal passkey_class, model_class.passkeys_class
    end

    test "find_for_passkey: finds the instance for a given passkey" do
      assert_equal model_instance, model_class.find_for_passkey(passkey_instance)
    end

    test "after_passkey_authentication: is defined" do
      assert_equal true, model_instance.respond_to?(:after_passkey_authentication)
    end

    test "webauthn_id: is required and cannot be blank" do
      instance = model_instance
      instance.webauthn_id = ""
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:webauthn_id, :blank)

      instance.webauthn_id = SecureRandom.hex
      assert_equal true, instance.valid?
    end

    test "webauthn_id: is unique" do
      instance = model_class.new(webauthn_id: model_instance.webauthn_id)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:webauthn_id, :taken)

      instance.webauthn_id = SecureRandom.hex
      instance.valid?

      assert_equal false, instance.errors.of_kind?(:webauthn_id, :taken)
    end
  end
end