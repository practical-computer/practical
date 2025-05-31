# frozen_string_literal: true

users.create_labeled(:one_invite_only) => one_invite_only_user
users.create_labeled(:only_used_invites)
users.create_labeled(:only_hidden_invites)
users.create_labeled(:multiple_open_invites)
users.create_labeled(:one_invite_of_each_type)

def create_dummy_organization(label:)
  organizations.create(label, name: Faker::Company.name).tap do |organization|
    organization.memberships.organization_manager.active.create!(user: users.create(:"#{label}_manager"))
  end
end

create_dummy_organization(label: :invite_organization_1)
create_dummy_organization(label: :invite_organization_2) => invite_organization_2
create_dummy_organization(label: :invite_organization_3)

def membership_invitations.create_labeled(label, email:, organization:, sender:)
  create(label, email: email,
                membership_type: :staff,
                organization: organization,
                sender: sender
        )
end


membership_invitations.create_labeled(:one_invite_only, email: one_invite_only_user.email,
                                                               organization: invite_organization_2,
                                                               sender: invite_organization_2.users.first
                                     )
