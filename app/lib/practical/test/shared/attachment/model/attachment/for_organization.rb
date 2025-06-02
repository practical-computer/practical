# frozen_string_literal: true

module Practical::Test::Shared::Attachment::Model::Attachment::ForOrganization
  extend ActiveSupport::Concern

  included do
    test "belongs_to the organization" do
      reflection = model_class.reflect_on_association(:organization)
      assert_equal :belongs_to, reflection.macro
    end

    test "belongs_to the user_reflection_name" do
      reflection = model_class.reflect_on_association(user_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "validates that the user has a membership in the organization" do
      attachment = valid_new_attachment

      assert_not_includes other_user.organizations, attachment.organization

      attachment.user = other_user

      assert_equal false, attachment.valid?
      assert_equal true, attachment.errors.of_kind?(:user, :cannot_access_organization)

      attachment.user = regular_user_in_organization
      assert_equal true, attachment.valid?

      attachment.user = admin_user_in_organization
      assert_equal true, attachment.valid?

      attachment.save!

      attachment.user = other_user
      assert_equal true, attachment.valid?
    end
  end
end