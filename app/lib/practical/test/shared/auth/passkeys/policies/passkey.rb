# frozen_string_literal: true

module Practical::Test::Shared::Auth::Passkeys::Policies::Passkey
  extend ActiveSupport::Concern

  included do
    test "manage?: only true for the user's passkeys" do
      passkey = resource_with_passkeys.passkeys.create!(
        label: SecureRandom.hex,
        external_id: SecureRandom.hex,
        public_key: SecureRandom.hex
      )

      assert_equal true, policy_class.new(passkey, user: resource_with_passkeys).apply(:manage?)
      assert_equal false, policy_class.new(passkey, user: other_resource_with_passkeys).apply(:manage?)
    end
  end
end