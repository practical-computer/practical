# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/passkey_mailer
class PasskeyMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/passkey_mailer/passkey_added
  def passkey_added
    PasskeyMailer.passkey_added(passkey: Passkey.last)
  end
end
