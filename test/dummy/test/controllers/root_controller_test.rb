require "test_helper"

class RootControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_redirected_to new_user_session_url

    user = users.user_1
    sign_in(user)

    get root_url
    assert_response :success
  end
end
