# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Controllers::EmergencyRegistration::SelfService
  extend ActiveSupport::Concern

  included do
    test "new: renders successfully" do
      get_new_registration_action
      assert_response :success
    end

    test "create: calls service to send emergency passkey registration with the user_agent, ip_address, and found owner" do
      owner = owner_instance

      params = {
        new_emergency_passkey_registration_form: {
          email: owner.email
        }
      }

      ip_address = Faker::Internet.ip_v6_address
      user_agent = Faker::Internet.user_agent

      env = {"REMOTE_ADDR" => ip_address, "User-Agent" => user_agent}

      service_spy = Spy.on_instance_method(send_registration_service_class, run!: true)

      request_emergency_registration_action(params: params, env: env)

      assert_json_redirected_to expected_new_session_url
      assert_flash_message(
        type: :notice,
        message: I18n.translate('emergency_passkey_registrations.sent_message'),
        icon_name: "envelope-dot"
      )

      assert_times_called(spy: service_spy, times: 1)
    end

    test "create: silently ignores bad email addresses" do
      params = {
        new_emergency_passkey_registration_form: {
          email: "bad@example.com"
        }
      }

      ip_address = Faker::Internet.ip_v6_address
      user_agent = Faker::Internet.user_agent

      env = {"REMOTE_ADDR" => ip_address, "User-Agent" => user_agent}

      service_spy = Spy.on_instance_method(send_registration_service_class, run!: true)

      request_emergency_registration_action(params: params, env: env)

      assert_json_redirected_to expected_new_session_url
      assert_flash_message(
        type: :notice,
        message: I18n.translate('emergency_passkey_registrations.sent_message'),
        icon_name: "envelope-dot"
      )

      assert_times_called(spy: service_spy, times: 0)
    end
  end
end