# frozen_string_literal: true

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Helpers::Passkey::System::RackTest
  include Practical::Test::Shared::Auth::Passkeys::Controllers::Sessions::Base

  def get_new_session_url
    get new_user_session_url
  end

  def issue_new_challenge_action
    post new_user_session_challenge_url
  end

  def get_session_challenge
    session["user_current_webauthn_authentication_challenge"]
  end

  alias_method :expected_stored_challenge, :get_session_challenge

  def expected_credentials_to_allow
    users.user_1.passkeys
  end

  def assert_redirected_to_new_session_url
    assert_redirected_to new_user_session_url
  end

  def authenticate_action(params:)
    post user_session_url, params: params
  end

  def sign_in_as_resource
    sign_in(users.user_1)
  end

  def resource_key
    :user
  end

  def client
    fake_client(origin: relying_party_origin, authenticator: fake_authenticator)
  end

  def assert_resource_not_signed_in
    assert_nil session["warden.user.user.key"]
  end

  def assert_resource_signed_in
    assert_equal users.user_1.id, session["warden.user.user.key"][0][0]
  end

  def remember_cookie_value
    cookies["remember_user_token"]
  end

  def assert_resource_remembered
    assert_not_nil remember_cookie_value
    assert_not_nil users.user_1.remember_created_at
  end

  def invalidate_all_credentials
    users.user_1.passkeys.map{|x| x.update!(external_id: SecureRandom.hex)}
  end

  setup do
    create_passkey_for_user_and_return_webauthn_credential(user: users.user_1)
  end
end

class Users::SessionsControllerCrossPollinationTest < ActionDispatch::IntegrationTest
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Helpers::Passkey::System::RackTest
  include Practical::Test::Shared::Auth::Passkeys::Controllers::Sessions::CrossPollination

  def issue_new_challenge_action
    post new_user_session_challenge_url
  end

  def get_session_challenge
    session["user_current_webauthn_authentication_challenge"]
  end

  alias_method :expected_stored_challenge, :get_session_challenge

  def sign_in_as_other_resource
    sign_in(other_resource, scope: :moderator)
  end

  def other_resource
    moderators.moderator_1
  end

  def resource_key
    :user
  end

  def client
    fake_client(origin: relying_party_origin, authenticator: fake_authenticator)
  end

  def authenticate_action(params:)
    post user_session_url, params: params
  end

  def assert_resource_not_signed_in
    assert_nil session["warden.user.user.key"]
  end

  setup do
    create_passkey_for_user_and_return_webauthn_credential(user: other_resource)
  end
end