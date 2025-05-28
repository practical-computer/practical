# frozen_string_literal: true

module Practical::Test::Shared::Models::User
  extend ActiveSupport::Concern

  included do
    test "name: required and cannot be blank" do
      instance = model_instance
      instance.name = ""
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:name, :blank)

      instance.name = Faker::Name.name
      assert_equal true, instance.valid?
    end

    test "email: required and cannot be blank" do
      instance = model_instance
      instance.email = ""
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:email, :blank)

      instance.email = Faker::Internet.email
      assert_equal true, instance.valid?
    end
  end
end