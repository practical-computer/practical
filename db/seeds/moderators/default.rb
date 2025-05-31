# frozen_string_literal: true

moderator_1 = moderators.create_labeled(:moderator_1)

moderator_passkeys.create(:moderator_1_passkey,
                          unique_by: :moderator,
                          moderator: moderator_1,
                          label: "Passkey 1",
                          external_id: SecureRandom.hex,
                          public_key: SecureRandom.hex
)

moderator_1.emergency_passkey_registrations.create!

moderator_2 = moderators.create_labeled(:moderator_2)

moderator_passkeys.create(:moderator_2_passkey,
                          unique_by: :moderator,
                          moderator: moderator_2,
                          label: "Passkey 2",
                          external_id: SecureRandom.hex,
                          public_key: SecureRandom.hex
)

moderator_passkeys.create(:moderator_1_passkey_2,
                          unique_by: :moderator,
                          moderator: moderator_1,
                          label: "Passkey 3",
                          external_id: SecureRandom.hex,
                          public_key: SecureRandom.hex
)

moderator_1.emergency_passkey_registrations.create!(
  used_at: 1.week.ago,
  passkey: moderator_passkeys.moderator_1_passkey_2
)