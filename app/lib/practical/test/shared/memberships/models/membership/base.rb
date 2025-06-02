# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Models::Membership::Base
  extend ActiveSupport::Concern

  included do
    test "state: has at least the base set of cases" do
      expected_states = [
        :pending_reacceptance,
        :active,
        :archived_by_organization,
        :archived_by_user,
      ].map(&:to_sym).to_set

      actual = model_class.states.keys.map(&:to_sym).to_set

      assert expected_states.subset?(actual), [expected_states, actual]
    end

    test "belongs_to the user resource" do
      reflection = model_class.reflect_on_association(user_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "belongs_to the organization resource" do
      reflection = model_class.reflect_on_association(organization_reflection_name)
      assert_equal :belongs_to, reflection.macro
    end

    test "user: must be unique for an organization" do
      instance = model_instance

      assert_equal true, instance.valid?

      new_instance = instance.send(:"#{user_reflection_name}").memberships.build(organization: organization_instance)

      assert_equal false, new_instance.valid?
      assert_equal true, new_instance.errors.of_kind?(:user, :taken)

      new_instance = other_user_instance.memberships.build(organization: instance.organization)
      new_instance.valid?
      assert_equal false, new_instance.errors.of_kind?(:user, :taken)
    end
  end
end