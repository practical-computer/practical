# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Models::User::Base
  extend ActiveSupport::Concern

  included do
    test "has_many membership resource" do
      reflection = model_class.reflect_on_association(membership_reflection_name)
      assert_equal :has_many, reflection.macro
    end

    test "has_many membership_invitations resource" do
      reflection = model_class.reflect_on_association(membership_invitation_reflection_name)
      assert_equal :has_many, reflection.macro
    end

    test "has_many organizations resource, through: :memberships resource" do
      reflection = model_class.reflect_on_association(organization_reflection_name)
      assert_equal :has_many, reflection.macro
      assert_equal membership_reflection_name, reflection.options[:through]
    end
  end
end