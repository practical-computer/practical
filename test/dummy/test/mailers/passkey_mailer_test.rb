# frozen_string_literal: true

require "test_helper"

class PasskeyMailerTest < ActionMailer::TestCase
  test "passkey_added" do
    passkey = users.user_1.passkeys.first
    mail = PasskeyMailer.passkey_added(passkey: passkey)
    assert_equal "Passkey added", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match passkey.label, mail.body.encoded
  end
end
