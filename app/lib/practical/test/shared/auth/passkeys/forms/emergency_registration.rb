# frozen_string_literal: true

require 'ostruct'

module Practical::Test::Shared::Auth::Passkeys::Forms::EmergencyRegistration
  extend ActiveSupport::Concern

  def dummy_webauthn_credential
    OpenStruct.new(public_key: SecureRandom.hex, raw_id: SecureRandom.bytes(10), sign_count: 0)
  end

  included do
    test "save: merges errors from the attempted new passkey and re-raises" do
      form = form_instance_with_no_passkey_label_or_public_key

      assert_no_difference "#{passkey_class}.count" do
      assert_raises ActiveRecord::RecordInvalid do
        form.save!
      end
      end

      assert_equal true, form.errors.of_kind?(:public_key, :blank)
      assert_equal true, form.errors.of_kind?(:passkey_label, :blank)
    end

    test "save: raises unexpected errors" do
      form = valid_form_instance
      Spy.on(form.emergency_registration, :use_for_and_notify!).and_raise(ArgumentError)

      assert_no_difference "#{passkey_class}.count" do
      assert_raises ArgumentError do
        form.save!
      end
      end
    end

    test "save: raises an AlreadyUsedError if the emergency_registration has a passkey" do
      form = form_instance_with_emergency_registration_that_has_passkey

      assert_no_difference "#{passkey_class}.count" do
      assert_raises already_used_error_class do
        form.save!
      end
      end
    end

    test "save: raises an AlreadyUsedError if the emergency_registration has been used" do
      form = form_instance_with_emergency_registration_with_used_at

      assert_no_difference "#{passkey_class}.count" do
      assert_raises already_used_error_class do
        form.save!
      end
      end
    end

    test """save:
      - creates the passkey for the owner
      - marks the emergency_registration as used
      - enqueues the email that a passkey has been created
    """ do
      form = valid_form_instance

      time = Time.now.utc

      Timecop.freeze(time) do
      assert_difference "#{passkey_class}.count", +1 do
        form.save!
      end
      end

      emergency_registration = form.emergency_registration.reload

      new_passkey = passkey_class.last
      assert_equal new_passkey, emergency_registration.passkey
      assert_equal time.to_formatted_s(:db), emergency_registration.used_at.to_formatted_s(:db)

      assert_new_passkey_email(new_passkey: new_passkey)
    end
  end
end