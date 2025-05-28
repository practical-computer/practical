# frozen_string_literal: true

module Practical::Test::Helpers::Setup::Simplecov
  extend ActiveSupport::Concern

  if ENV['COVERAGE']
    included do
      parallelize_setup do |worker|
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end

      parallelize_teardown do |worker|
        SimpleCov.result
      end
    end
  end
end