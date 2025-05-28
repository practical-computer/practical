# frozen_string_literal: true

require "test_helper"
require "generators/practical/test/helper/helper_generator"

class Practical::Test::HelperGeneratorTest < Rails::Generators::TestCase
  tests Practical::Test::HelperGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator ["assertions"]
      assert_file "app/lib/practical/test/helpers/assertions.rb"
    end
  end
end
