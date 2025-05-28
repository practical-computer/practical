# frozen_string_literal: true

require "test_helper"
require "generators/practical/views/component/component_generator"

class Practical::Views::ComponentGeneratorTest < Rails::Generators::TestCase
  tests Practical::Views::ComponentGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator ["custom_icon", "name"]
      assert_file "app/components/practical/views/custom_icon_component.rb"
    end
  end

  test "generator runs namespaced without errors" do
    assert_nothing_raised do
      run_generator ["custom/icon", "name"]
      assert_file "app/components/practical/views/custom/icon_component.rb"
    end
  end
end
