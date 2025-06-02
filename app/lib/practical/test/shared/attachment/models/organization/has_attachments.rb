# frozen_string_literal: true

module Practical::Test::Shared::Attachment::Models::Organization::HasAttachments
  extend ActiveSupport::Concern

  included do
    test "has_many: attachments" do
      reflection = model_class.reflect_on_association(:attachments)
      assert_equal :has_many, reflection.macro
    end
  end
end