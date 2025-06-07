# frozen_string_literal: true

module Practical::Test::Helpers::System::Assertions
  def assert_toast_message(text:)
    within(".notification-messages") do
      assert_selector("dialog", text: text, visible: :all)
    end
  end

  def assert_sign_in_user(user:)
    create_passkey_for_user_and_return_webauthn_credential(
      user: user
    )

    if Capybara.current_driver == :rack_test
      page.driver.browser.post(new_user_session_challenge_url, as: :json)
      challenge_data = JSON.parse(page.driver.response.body)
    end

    visit new_user_session_url

    fill_in "Email", with: user.email

    if Capybara.current_driver == :rack_test
      credential_data = user_webauthn_client.get(challenge: challenge_data["challenge"], user_verified: true)
      find("input[type=hidden]#user_passkey_credential", visible: false).set(JSON.generate(credential_data))
    end

    click_on "Sign in"

    assert_toast_message(text: I18n.translate("devise.sessions.signed_in"))
  end
end