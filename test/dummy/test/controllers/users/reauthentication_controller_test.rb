# frozen_string_literal: true

require "test_helper"

class Users::ReauthenticationControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Shared::Auth::Passkeys::Controllers::Reauthentication::Base
  include Practical::Test::Shared::Auth::Passkeys::Controllers::Reauthentication::CrossPollination
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Helpers::Passkey::System::RackTest


  setup do
    get new_user_session_url
  end

  def issue_new_challenge_action
    post new_user_reauthentication_challenge_url
  end

  def get_session_challenge
    session["user_current_reauthentication_challenge"]
  end

  alias_method :expected_stored_challenge, :get_session_challenge

  def get_reauthentication_token
    session["user_current_reauthentication_token"]
  end

  alias_method :expected_stored_reauthentication_token, :get_reauthentication_token

  def expected_credentials_to_allow
    users.user_1.passkeys
  end

  def assert_redirected_to_new_session_url
    assert_redirected_to new_user_session_url
  end

  def reauthenticate_action(params:)
    post user_reauthentication_url, params: params, as: :json
  end

  def sign_in_as_resource
    sign_in(users.user_1)
  end

  def sign_in_as_other_resource
    sign_in(moderators.moderator_1, scope: :moderator)
  end

  def client
    fake_client(origin: relying_party_origin, authenticator: fake_authenticator)
  end

  def assert_resource_not_signed_in
    assert_nil session["warden.user.user.key"]
  end

  def invalidate_all_credentials
    users.user_1.passkeys.map{|x| x.update!(external_id: SecureRandom.hex)}
  end

  def assert_new_challenge_authorized(&block)
    assert_authorized_to(:manage?, users.user_1, with: UserPolicy, &block)
  end

  alias_method :assert_reauthentication_authorized, :assert_new_challenge_authorized

  setup do
    create_passkey_for_user_and_return_webauthn_credential(user: users.user_1)
  end
end