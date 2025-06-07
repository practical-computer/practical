# frozen_string_literal: true

module Practical::Test::Helpers::Setup::Debug
  extend ActiveSupport::Concern
  included do
    # rubocop:disable Rails/Output
    puts "MINITEST_PARALLEL_EXECUTOR_SIZE: #{Minitest.parallel_executor.size}"
    puts "PARALLEL_WORKERS: #{ENV["PARALLEL_WORKERS"]}"
    # rubocop:enable Rails/Output
  end
end