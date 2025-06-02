# frozen_string_literal: true

require "test_helper"

class MembershipInvitationsControllerTest < ActionDispatch::IntegrationTest
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Helpers::Passkey::System::RackTest
  include Practical::Test::Shared::Memberships::Controllers::MembershipInvitations::Base
  include Practical::Test::Shared::Memberships::Controllers::MembershipInvitations::RegisterWithPasskey

  setup do
    get new_user_session_url
  end

  def resource_instance
    users.invited_user_1
  end

  def resource_instance_with_different_email
    users.organization_2_owner
  end

  def available_invitation
    MembershipInvitation.find_by!(email: resource_instance.email)
  end

  def visible_unused_token
    membership_invitation = available_invitation
    membership_invitation.generate_token_for(:invitation)
  end

  def used_token
    membership_invitation = users.invited_user_2.membership_invitations.first
    membership_invitation.generate_token_for(:invitation)
  end

  def hidden_token
    membership_invitation = available_invitation
    membership_invitation.update!(visible: false)
    membership_invitation.generate_token_for(:invitation)
  end

  def bad_token
    SecureRandom.hex
  end

  def raw_token
    MembershipInvitation.find_by!(email: users.invited_user_1.email).id
  end

  def show_membership_invitation_action(token:)
    get membership_invitation_url(token)
  end

  def sign_in_as_resource
    sign_in(users.invited_user_1)
  end

  def sign_in_as_resource_with_different_email
    sign_in(resource_instance_with_different_email)
  end

  def sign_in_as_resource_already_in_organization
    sign_in(users.organization_3_owner)
  end

  def membership_class
    Membership
  end

  def params_for_registration_challenge(email:, passkey_label:)
    {create_new_user_with_membership_invitation_form: {email: email, passkey_label: passkey_label}}
  end

  def params_for_registration(email:, passkey_label:, raw_credential:)
    {create_new_user_with_membership_invitation_form: {email: email, name: Faker::Name.name, passkey_label: passkey_label, passkey_credential: raw_credential.to_json}}
  end

  def new_registration_challenge_action(token:, params:)
    post new_create_challenge_membership_invitation_url(token), params: params, as: :json
  end

  def create_resource_action(token:, params:)
    post create_user_and_use_membership_invitation_url(token), params: params
  end

  def accept_as_current_user_action(token:)
    patch accept_as_current_user_membership_invitation_url(token)
  end

  def sign_out_then_show_action(token:)
    delete sign_out_then_show_membership_invitation_url(token)
  end

  def assert_redirected_to_organization
    membership_invitation = available_invitation
    assert_redirected_to organization_url(membership_invitation.organization)
  end

  def create_resource_success_url
    new_user_session_url
  end

  def assert_accepted_invitation_flash_message
    membership_invitation = available_invitation
    message = I18n.t('membership_invitations.accepted_message', organization_name: membership_invitation.organization.name)
    assert_flash_message(type: :success, message: message, icon_name: 'solid-warehouse-circle-check')
  end

  def assert_resource_created_flash_message
    message = I18n.t('membership_invitations.registered_message')
    assert_flash_message(type: :success, message: message, icon_name: 'circle-check')
  end

  def assert_taken_flash_message
    message = I18n.t('activerecord.errors.models.membership.attributes.user.taken')
    assert_flash_message(type: :alert, message: message, icon_name: 'triangle-exclamation')
  end

  def assert_membership_accepted_for_resource(resource:)
    membership = available_invitation.reload.membership

    assert_equal true, membership.active?
    assert_equal resource, membership.user
    assert_equal resource, available_invitation.user

    assert_equal available_invitation.organization, membership.organization
    assert_equal available_invitation.membership_type, membership.membership_type
  end

  def assert_user_created_and_membership_accepted
    membership = available_invitation.reload.membership
    resource = resource_class.last

    assert_equal true, membership.active?
    assert_equal resource, membership.user
    assert_equal resource, available_invitation.user

    assert_equal available_invitation.organization, membership.organization
    assert_equal available_invitation.membership_type, membership.membership_type
  end

  def assert_membership_invitation_unclaimed
    assert_nil available_invitation.reload.membership
  end

  def assert_redirected_to_invitation(token:)
    assert_redirected_to membership_invitation_url(token)
  end

  def expected_stored_challenge
    session["user_from_invitation_creation_challenge"]
  end

  def expected_relying_party_data
    {"name"=> I18n.translate("app_title.text")}
  end

  def expected_user_data_for_challenge(email:, webauthn_id:, name:)
    {"name"=>email, "id"=>webauthn_id, "displayName"=>name}
  end

  def assert_email_missing_error_message
    expected = {"message" => I18n.translate("devise.registrations.email_missing")}
    assert_equal expected, response.parsed_body
  end

  def assert_passkey_label_missing_error_message
    expected = {"message" => I18n.translate("devise.registrations.passkey_label_missing")}
    assert_equal expected, response.parsed_body
  end

  def webauthn_client
    user_webauthn_client
  end

  def webauthn_relying_party
    relying_party
  end

  def passkey_class
    Passkey
  end

  def resource_class
    User
  end
end
