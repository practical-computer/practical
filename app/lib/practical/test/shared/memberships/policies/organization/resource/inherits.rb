# frozen_string_literal: true

module Practical::Test::Shared::Memberships::Policies::Organization::Resource::Inherits
  extend ActiveSupport::Concern
  included do
    test "is a subclass of the resource_policy_class" do
      assert_includes policy_class.ancestors, resource_policy_class
    end
  end
end