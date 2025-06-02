# frozen_string_literal: true

require "test_helper"

class MembershipInvitationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Models::NormalizedEmail
  include Practical::Test::Shared::Memberships::Models::MembershipInvitation::Base
  include Practical::Test::Shared::Memberships::Models::MembershipInvitation::Sending
  include Practical::Test::Shared::Memberships::Models::MembershipInvitation::UseForAndNotify

  def model_instance
    users.invited_user_2.membership_invitations.first
  end

  def model_class
    MembershipInvitation
  end

  def user_reflection_name
    :user
  end

  def user_class
    User
  end

  def organization_reflection_name
    :organization
  end

  def organization_class
    Organization
  end

  def membership_reflection_name
    :membership
  end

  def membership_class
    Membership
  end

  def sender_reflection_name
    :sender
  end

  def organization_instance
    organizations.organization_1
  end

  def user_instance
    users.organization_3_owner
  end

  def other_user_instance_with_admin_privledges
    users.organization_3_owner
  end

  def other_user_instance_without_admin_privledges
    users.works_at_org_1_and_2
  end

  def user_in_organization
    users.organization_1_owner
  end

  def invited_user_instance
    users.invited_user_1
  end

  def instance_with_user
    users.invited_user_2.membership_invitations.first
  end

  def other_user
    users.user_2
  end

  def additional_membership_accept_assertions(invitation:)
    assert_equal invitation.membership_type, invitation.membership.membership_type
  end

  def mailer_class
    MembershipInvitationMailer
  end

  def valid_new_instance
    MembershipInvitation.new(
      organization: organizations.organization_1,
      sender: users.organization_1_owner,
      email: Faker::Internet.email,
      membership_type: :staff
    )
  end

  def create_new_instance(organization:, email:)
    sender = organization.memberships.organization_manager.first.user
    organization.membership_invitations.create!(sender: sender, email: email, membership_type: :staff)
  end

  def hidden_instance
    MembershipInvitation.create!(
      visible: false,
      email: Faker::Internet.email,
      membership_type: :organization_manager,
      organization: organizations.organization_1,
      sender: users.organization_1_manager
    )
  end

  test "invitations can be created for each Membership.membership_type" do
    organization = organizations.organization_1
    Membership.membership_types.keys.each do |membership_type|
      email = Faker::Internet.email
      x = organization.membership_invitations.build(email: email, membership_type: membership_type)
      assert_equal x.membership_type, membership_type
    end
  end
end
