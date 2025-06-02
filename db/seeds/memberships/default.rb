# frozen_string_literal: true

organization_1 = organizations.create(:organization_1,
                                      name: Faker::Company.name
)

organization_2 = organizations.create(:organization_2,
                                      name: Faker::Company.name
)

organization_3 = organizations.create(:organization_3,
                                      name: Faker::Company.name
)

organization_1_owner = users.create_labeled(:organization_1_owner)
organization_2_owner = users.create_labeled(:organization_2_owner)
organization_3_owner = users.create_labeled(:organization_3_owner)

organization_1.memberships.create!(user: organization_1_owner, state: :active, membership_type: :organization_manager)
organization_2.memberships.create!(user: organization_2_owner, state: :active, membership_type: :organization_manager)
organization_3.memberships.create!(user: organization_3_owner, state: :active, membership_type: :organization_manager)

organization_1_manager = users.create_labeled(:organization_1_manager)

organization_1.memberships.create!(user: organization_1_manager,
                                   state: :active,
                                   membership_type: :organization_manager
                                  )

works_at_org_1_and_2 = users.create_labeled(:works_at_org_1_and_2)

organization_1.memberships.create!(user: works_at_org_1_and_2, state: :active, membership_type: :staff)
organization_2.memberships.create!(user: works_at_org_1_and_2, state: :active, membership_type: :staff)

organization_1_staff = users.create_labeled(:organization_1_staff)
organization_2.memberships.create!(user: organization_1_staff, state: :pending_reacceptance, membership_type: :staff)

retired_staff = users.create_labeled(:retired_staff)
organization_1.memberships.create!(user: retired_staff, state: :archived_by_organization, membership_type: :staff)

archived_organization_1_manager = users.create_labeled(:archived_organization_1_manager)
organization_1.memberships.create!(user: archived_organization_1_manager,
                                   state: :archived_by_organization,
                                   membership_type: :organization_manager
                                  )

invited_user_1 = users.create_labeled(:invited_user_1)
invited_user_2 = users.create_labeled(:invited_user_2)

organization_3.membership_invitations.create!(
  email: Faker::Internet.email,
  sender: organization_3_owner,
  membership_type: :staff
)

organization_3.membership_invitations.create!(
  email: invited_user_1.email,
  sender: organization_3_owner,
  membership_type: :staff
)

organization_3.membership_invitations.create!(
  user: invited_user_2,
  email: invited_user_2.email,
  sender: organization_3_owner,
  membership: organization_3.memberships.create!(user: invited_user_2, state: :active, membership_type: :staff),
  membership_type: :staff
)
