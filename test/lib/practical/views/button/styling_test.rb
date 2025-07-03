# frozen_string_literal: true

require "test_helper"

class Practical::Views::Button::StylingTest < ActiveSupport::TestCase
  class TestClass
    include Practical::Views::Button::Styling

    attr_accessor :appearance, :color_variant, :size

    def initialize(appearance: nil, color_variant: nil, size: nil)
      initialize_style_utilities(appearance: appearance, color_variant: color_variant, size: size)
    end

    def helpers
      ApplicationController.helpers
    end
  end

  def assert_css_classes(expected:, options:)
    assert_equal expected, TestClass.new(**options).css_classes_from_style_utilities
  end

  def assert_web_awesome_attributes_hash(expected:, options:)
    assert_equal expected, TestClass.new(**options).attributes_from_style_utilities
  end

  test "no styling provided" do
    assert_css_classes(expected: "", options: {})
    assert_web_awesome_attributes_hash(expected: {}, options: {})
  end

  test "appearance styling provided" do
    assert_css_classes(expected: "wa-filled", options: {appearance: "filled"})
    assert_css_classes(expected: "wa-filled wa-outline", options: {appearance: "filled outline"})

    assert_web_awesome_attributes_hash(expected: {appearance: "filled"}, options: {appearance: "filled"})
    assert_web_awesome_attributes_hash(expected: {appearance: "filled outline"}, options: {appearance: "filled outline"})
  end

  test "color_variant styling provided" do
    assert_css_classes(expected: "wa-success", options: {color_variant: "success"})
    assert_web_awesome_attributes_hash(expected: {variant: "success"}, options: {color_variant: "success"})
  end

  test "size styling provided" do
    assert_css_classes(expected: "wa-size-s", options: {size: "small"})
    assert_css_classes(expected: "wa-size-s", options: {size: "s"})
    assert_css_classes(expected: "wa-size-s", options: {size: "wa-size-s"})

    assert_web_awesome_attributes_hash(expected: {size: "small"}, options: {size: "small"})
    assert_web_awesome_attributes_hash(expected: {size: "small"}, options: {size: "s"})
    assert_web_awesome_attributes_hash(expected: {size: "small"}, options: {size: "wa-size-s"})
  end

  test "multiple stylings provided" do
    assert_css_classes(expected: "wa-filled wa-outline wa-size-s", options: {size: "small", appearance: ["filled", "outline"]})
    assert_css_classes(expected: "wa-plain wa-success", options: {color_variant: :success, appearance: :plain})
    assert_css_classes(expected: "wa-plain wa-success wa-size-l", options: {color_variant: :success, appearance: :plain, size: :large})

    assert_web_awesome_attributes_hash(
      expected: {appearance: "filled outline", size: "small"},
      options: {size: "small", appearance: ["filled", "outline"]}
    )
    assert_web_awesome_attributes_hash(
      expected: {appearance: "plain", variant: "success"},
      options: {color_variant: :success, appearance: :plain}
    )
    assert_web_awesome_attributes_hash(
      expected: {appearance: "plain", variant: "success", size: "large"},
      options: {color_variant: :success, appearance: :plain, size: :large}
    )
  end
end