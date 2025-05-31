# frozen_string_literal: true

module Practical::Test::Shared::Models::NormalizedEmail
  extend ActiveSupport::Concern

  included do
    test "email: is normalized to lowercase and stripped" do
      instance = model_instance
      original_email = instance.email
      normalized_email = instance.email.strip.downcase
      instance = model_instance

      instance.update!(email: original_email.upcase)
      assert_equal instance, model_class.find_by(email: original_email.upcase)
      assert_equal normalized_email, model_class.find_by(email: original_email.upcase).email

      instance.update!(email: "\n\n\t#{original_email.upcase}\n\n\t")
      assert_equal instance, model_class.find_by(email: "\n\n\t#{original_email.upcase}\n\n\t")
      assert_equal normalized_email, model_class.find_by(email: "\n\n\t#{original_email.upcase}\n\n\t").email
    end
  end
end