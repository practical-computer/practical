# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Models::MembershipInvitation::Base
  extend ActiveSupport::Concern

  included do
    test "belongs_to an organization" do
      reflection = model_class.reflect_on_association(organization_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "optionally belongs_to a user" do
      reflection = model_class.reflect_on_association(user_reflection_name)
      assert_equal :belongs_to, reflection.macro
      assert_equal user_class.to_s, reflection.class_name
      assert_equal true, reflection.options[:optional]
    end

    test "optionally belongs_to a membership" do
      reflection = model_class.reflect_on_association(membership_reflection_name)
      assert_equal :belongs_to, reflection.macro
      assert_equal membership_class.to_s, reflection.class_name
      assert_equal true, reflection.options[:optional]
    end

    test "does not require a membership or user" do
      instance = valid_new_instance
      assert_equal true, instance.valid?
      assert_nil valid_new_instance.user
      assert_nil valid_new_instance.membership
    end

    test "requires an organization" do
      instance = valid_new_instance
      instance.organization = nil
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(organization_reflection_name, :blank)
    end

    test "requires a non-blank email" do
      instance = valid_new_instance
      instance.email = nil
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:email, :blank)

      instance.email = ""
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:email, :blank)

      instance.email = "    "
      assert_equal false, instance.valid?
      assert_equal true, instance.errors.of_kind?(:email, :blank)
    end

    test "an organization can only create 1 invitation per email" do
      organization = organization_instance
      email = Faker::Internet.email
      instance_1 = create_new_instance(organization: organization, email: email)

      duplicate_instance = valid_new_instance
      duplicate_instance.email = email
      duplicate_instance.organization = organization

      assert_equal false, duplicate_instance.valid?
      assert_equal true, duplicate_instance.errors.of_kind?(:email, :taken)
    end

    test "unused scope returns all unused invitations" do
      assert_equal true, model_class.all.any?{|x| x.user.present?}

      invitations = model_class.unused
      assert_not_empty invitations
      assert_equal true, invitations.all?{|x| x.user.nil? }
    end

    test "visible scope returns all visible invitations" do
      hidden_invitation = hidden_instance

      assert_equal false, hidden_invitation.visible?

      assert_not_empty model_class.visible
      assert_not_includes model_class.visible, hidden_invitation
    end
  end
end