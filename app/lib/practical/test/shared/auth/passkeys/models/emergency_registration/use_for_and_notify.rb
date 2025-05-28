# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Models::EmergencyRegistration::UseForAndNotify
  extend ActiveSupport::Concern

  included do
    test "use_for_and_notify!: raises AlreadyUsedError if a passkey is present" do
      instance = model_instance
      instance.update!(passkey: create_passkey_instance)
      assert_raises already_used_error_class do
        instance.use_for_and_notify!(new_passkey: create_passkey_instance)
      end
    end

    test "use_for_and_notify!: raises AlreadyUsed error used_at is present" do
      instance = model_instance
      instance.update!(used_at: Time.now)
      assert_raises already_used_error_class do
        instance.use_for_and_notify!(new_passkey: create_passkey_instance)
      end
    end

    test """use_for_and_notify!:
      - links to the given passkey
      - marks the used_at
      - matching PasskeyMailer.passkey_added class
    """ do
      instance = model_instance
      passkey_instance = create_passkey_instance

      time = Time.now.utc

      Timecop.freeze(time) do
        assert_enqueued_email_with(
          passkey_mailer_class,
          :passkey_added,
          args: [{ passkey: passkey_instance }]
        ) do
          instance.use_for_and_notify!(new_passkey: passkey_instance)
          instance.reload

          assert_equal passkey_instance, instance.passkey
          assert_equal time.to_formatted_s(:db), instance.used_at.to_formatted_s(:db)
        end
      end
    end
  end
end