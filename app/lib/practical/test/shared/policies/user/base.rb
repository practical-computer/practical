# frozen_string_literal: true

module Practical::Test::Shared::Policies::User::Base
  extend ActiveSupport::Concern
  included do
    test "manage?: only true for the user" do
      user = users.user_1
      other_user = users.user_2

      assert_equal true, policy_class.new(user, user: user).apply(:manage?)
      assert_equal false, policy_class.new(user, user: other_user).apply(:manage?)
    end
  end
end