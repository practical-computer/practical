# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Policies::Organization::BaseResource
  extend ActiveSupport::Concern
  included do
    class TestClass
      attr_accessor :organization

      def initialize(organization:)
        self.organization = organization
      end
    end

    class TestClassPolicy < policy_class
      def show?
        true
      end
    end

    test "pre_check? the record is part of the same_organization?" do
      organization = organizations.organization_1
      record = TestClass.new(organization: organization)
      other_record = TestClass.new(organization: organizations.organization_2)

      assert_equal true, TestClassPolicy.new(record, user: users.organization_1_owner, organization: organization).apply(:show?)
      assert_equal false, TestClassPolicy.new(other_record, user: users.organization_1_owner, organization: organization).apply(:show?)
    end
  end
end