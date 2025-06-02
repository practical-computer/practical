# frozen_string_literal: true

require "test_helper"

class Users::MembershipInvitationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include Practical::Test::Shared::Memberships::Controllers::User::MembershipInvitation

  def resource_instance
    users.invited_user_1
  end

  def other_resource_instance
    users.invited_user_2
  end

  def sign_in_as_resource(resource:)
    sign_in(resource)
  end

  def membership_invitation_class
    MembershipInvitation
  end

  def delete_invitation_action(membership_invitation:)
    delete user_hide_membership_invitation_url(membership_invitation)
  end

  def assert_policies_applied(resource:, membership_invitation:, &block)
    assert_have_authorized_scope(type: :active_record_relation, with: User::MembershipInvitationPolicy) do
    assert_authorized_to(:manage?, resource, with: UserPolicy) do
      assert_authorized_to(:manage?, membership_invitation, with: User::MembershipInvitationPolicy, &block)
    end
    end
  end

  def assert_policies_applied_on_404(resource:, &block)
    assert_have_authorized_scope(type: :active_record_relation, with: User::MembershipInvitationPolicy, &block)
  end
end