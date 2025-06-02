# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Controllers::User::MembershipInvitation
  extend ActiveSupport::Concern

  included do
    test "destroy: destroys a pending invitation and returns a flash message" do
      resource = resource_instance
      sign_in_as_resource(resource: resource)

      membership_invitation = membership_invitation_class.find_by!(email: resource.email)

      assert_policies_applied(resource: resource, membership_invitation: membership_invitation) do
      assert_difference "#{membership_invitation_class}.count", -1 do
        delete_invitation_action(membership_invitation: membership_invitation)
      end
      end

      assert_redirected_to user_memberships_url
      message = I18n.t('user_memberships.invitation_hidden_message', organization_name: membership_invitation.organization.name)
      assert_flash_message(type: :alert, message: message, icon_name: 'solid-warehouse-slash')
    end

    test "destroy: returns 404 if the invitation is already tied to a user" do
      resource = other_resource_instance
      sign_in_as_resource(resource: resource)

      membership_invitation = membership_invitation_class.find_by!(email: resource.email)

      assert_policies_applied_on_404(resource: resource) do
      assert_no_difference "membership_invitation_class.count" do
        delete_invitation_action(membership_invitation: membership_invitation)
      end
      end

      assert_response :not_found
      assert_no_enqueued_emails
    end

    test "destroy: returns 404 if the invitation is not visible" do
      resource = resource_instance
      sign_in_as_resource(resource: resource)

      membership_invitation = membership_invitation_class.find_by!(email: resource.email)
      membership_invitation.update!(visible: false)

      assert_policies_applied_on_404(resource: resource) do
      assert_no_difference "membership_invitation_class.count" do
        delete_invitation_action(membership_invitation: membership_invitation)
      end
      end

      assert_response :not_found
      assert_no_enqueued_emails
    end
  end
end