# frozen_string_literal: true

module Practical::Test::Shared::Models::Utility::UserAgent
  extend ActiveSupport::Concern

  included do
    test "user_agent: is required and cannot be blank" do
      instance = new_model_instance(user_agent: nil)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:user_agent, :blank)

      instance.user_agent = SecureRandom.hex

      assert_equal true, instance.valid?
      assert_equal false, instance.errors.of_kind?(:user_agent, :blank)
    end

    test "user_agent: is unique" do
      old_user_agent = SecureRandom.hex

      old_instance = new_model_instance(user_agent: old_user_agent)
      old_instance.save!

      instance = new_model_instance(user_agent: old_user_agent)
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:user_agent, :taken)

      instance.user_agent = SecureRandom.hex

      assert_equal true, instance.valid?
      assert_equal false, instance.errors.of_kind?(:user_agent, :taken)
    end

    test "upsert_user_agent: upserts a given IP Address" do
      user_agent = SecureRandom.hex

      assert_difference "#{model_class}.count", +1 do
        instance = model_class.upsert_user_agent(user_agent: user_agent)
        assert_equal model_class.upsert_user_agent(user_agent: user_agent), instance
      end
    end
  end
end