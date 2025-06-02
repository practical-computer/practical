# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Controllers::MembershipInvitations::Base
  extend ActiveSupport::Concern

  included do
    test "show: renders successfully when given a visible, unused membership_invitation token" do
      show_membership_invitation_action(token: visible_unused_token)
      assert_response :ok
    end

    test "show: returns 404 if a used membership_invitation token is given" do
      show_membership_invitation_action(token: used_token)
      assert_response :not_found
    end

    test "show: returns 404 if a hidden membership_invitation token is given" do
      show_membership_invitation_action(token: hidden_token)
      assert_response :not_found
    end

    test "show: raises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        show_membership_invitation_action(token: bad_token)
      end
    end

    test "show: raises ActiveSupport::MessageVerifier::InvalidSignature if a raw token is given" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        show_membership_invitation_action(token: raw_token)
      end
    end

    test "sign_out_then_show: signs out the resource, but stores the path and redirects them" do
      sign_in_as_resource

      sign_out_then_show_action(token: visible_unused_token)
      assert_redirected_to_invitation(token: visible_unused_token)
    end

    test "sign_out_then_show: returns 404 if a used membership_invitation token is given" do
      sign_in_as_resource

      sign_out_then_show_action(token: used_token)
      assert_response :not_found
    end

    test "sign_out_then_show: returns 404 if a hidden membership_invitation token is given" do
      sign_in_as_resource

      sign_out_then_show_action(token: hidden_token)
      assert_response :not_found
    end

    test "sign_out_then_show: raises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      sign_in_as_resource

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        sign_out_then_show_action(token: bad_token)
      end
    end

    test "sign_out_then_show: raises ActiveSupport::MessageVerifier::InvalidSignature if a raw token is given" do
      sign_in_as_resource

      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        sign_out_then_show_action(token: raw_token)
      end
    end

    test "accept_as_current_user: links the invitation to a given resource, creating the final membership" do
      sign_in_as_resource

      assert_difference "#{membership_class}.count", +1 do
        accept_as_current_user_action(token: visible_unused_token)
      end

      assert_redirected_to_organization
      assert_accepted_invitation_flash_message

      assert_membership_accepted_for_resource(resource: resource_instance)
    end

    test "accept_as_current_user: links the invitation to a given resource, even if the email does not match" do
      sign_in_as_resource_with_different_email

      assert_difference "#{membership_class}.count", +1 do
        accept_as_current_user_action(token: visible_unused_token)
      end

      assert_redirected_to_organization
      assert_accepted_invitation_flash_message

      assert_membership_accepted_for_resource(resource: resource_instance_with_different_email)
    end

    test "accept_as_current_user: raises an error and does not change the invitation if the resource is already a member of this organization" do
      sign_in_as_resource_already_in_organization

      assert_no_difference "#{membership_class}.count" do
        accept_as_current_user_action(token: visible_unused_token)
      end

      assert_response :unprocessable_entity
      assert_taken_flash_message

      assert_membership_invitation_unclaimed
    end

    test "accept_as_current_user: returns 404 if the resource is not signed in" do
      assert_no_difference "#{membership_class}.count" do
        accept_as_current_user_action(token: visible_unused_token)
      end

      assert_response :not_found
      assert_membership_invitation_unclaimed
    end

    test "accept_as_current_user: returns 404 if a used membership_invitation token is given" do
      sign_in_as_resource

      assert_no_difference "#{membership_class}.count" do
        accept_as_current_user_action(token: used_token)
      end

      assert_response :not_found
      assert_membership_invitation_unclaimed
    end

    test "accept_as_current_user: returns 404 if a hidden membership_invitation token is given" do
      sign_in_as_resource

      assert_no_difference "#{membership_class}.count" do
        accept_as_current_user_action(token: hidden_token)
      end

      assert_response :not_found
      assert_membership_invitation_unclaimed
    end

    test "accept_as_current_user: raises ActiveSupport::MessageVerifier::InvalidSignature if a bad token is given" do
      sign_in_as_resource

      assert_no_difference "#{membership_class}.count" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        accept_as_current_user_action(token: bad_token)
      end
      end

      assert_membership_invitation_unclaimed
    end

    test "accept_as_current_user: raises ActiveSupport::MessageVerifier::InvalidSignature if a raw token is given" do
      sign_in_as_resource

      assert_no_difference "#{membership_class}.count" do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        accept_as_current_user_action(token: raw_token)
      end
      end

      assert_membership_invitation_unclaimed
    end
  end
end