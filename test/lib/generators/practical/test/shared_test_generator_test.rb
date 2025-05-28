require "test_helper"
require "generators/practical/test/shared_test/shared_test_generator"

class Practical::Test::SharedTestGeneratorTest < Rails::Generators::TestCase
  tests Practical::Test::SharedTestGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator ["auth/models/user/base"]
      assert_file "app/lib/practical/test/shared/auth/models/user/base.rb"
    end
  end
end
