# frozen_string_literal: true

user_1 = users.create_labeled(:user_1)

passkeys.create(:user_1_passkey,
                unique_by: :user,
                user: user_1,
                label: "Passkey 1",
                external_id: SecureRandom.hex,
                public_key: SecureRandom.hex
)

user_1.emergency_passkey_registrations.create!

user_2 = users.create_labeled(:user_2)

passkeys.create(:user_2_passkey,
                unique_by: :user,
                user: user_2,
                label: "Passkey 2",
                external_id: SecureRandom.hex,
                public_key: SecureRandom.hex
)

passkeys.create(:user_1_passkey_2,
                unique_by: :user,
                user: user_1,
                label: "Passkey 3",
                external_id: SecureRandom.hex,
                public_key: SecureRandom.hex
)

user_1.emergency_passkey_registrations.create!(
  used_at: 1.week.ago,
  passkey: passkeys.user_1_passkey_2
)