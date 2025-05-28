# frozen_string_literal: true

require "application_system_test_case"

class User::RackSigninTest < ApplicationSystemTestCase
  test "can sign in with an existing passkey" do
    assert_sign_in_user(user: users.user_1)
  end
end

class User::BrowserSigninTest < SlowBrowserSystemTestCase
  test "can sign in with an existing passkey" do
    assert_sign_in_user(user: users.user_1)
  end
end