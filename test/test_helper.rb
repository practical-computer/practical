# frozen_string_literal: true

# Configure Rails Environment
if ENV['COVERAGE']
  require 'simplecov'
end

ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
require "rails/test_help"
require 'spy/integration'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

Timecop.safe_mode = true


module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
    include Practical::Test::Helpers::Setup::Simplecov
    include Practical::Test::Helpers::Setup::Debug
    include Practical::Test::Helpers::Setup::FakerSeedPinning

    include Oaken.loader.test_setup

    include Practical::Test::Helpers::SpyAssertions
    include Practical::Test::Helpers::ExtraAssertions
  end
end


class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Practical::Test::Helpers::FlashAssertions
  include Practical::Test::Helpers::Integration::Assertions
end