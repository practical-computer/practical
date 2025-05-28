# frozen_string_literal: true

module Practical::Test::Shared::Models::Utility::IPAddress
  extend ActiveSupport::Concern
  included do
    test "address: is required and cannot be blank" do
      instance = new_model_instance(address: nil)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:address, :blank)

      instance.address = Faker::Internet.ip_v6_address

      assert_equal true, instance.valid?
      assert_equal false, instance.errors.of_kind?(:address, :blank)
    end

    test "address: is unique" do
      old_ip = Faker::Internet.ip_v6_address

      old_instance = new_model_instance(address: old_ip)
      old_instance.save!

      instance = new_model_instance(address: old_ip)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:address, :taken)

      instance.address = Faker::Internet.ip_v6_address

      assert_equal true, instance.valid?
      assert_equal false, instance.errors.of_kind?(:address, :taken)
    end

    test "upsert_address: upserts a given IP Address" do
      ip = Faker::Internet.ip_v6_address

      assert_difference "#{model_class}.count", +1 do
        instance = model_class.upsert_address(address: ip)
        assert_equal model_class.upsert_address(address: ip), instance
      end
    end
  end
end