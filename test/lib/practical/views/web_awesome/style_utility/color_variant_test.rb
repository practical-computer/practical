# frozen_string_literal: true

require "test_helper"

class Practical::Views::WebAwesome::StyleUtility::ColorVariantTest < ActiveSupport::TestCase
  def assert_css_variant(expected:, variant:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::ColorVariant.css(variant: variant)
  end

  def assert_web_awesome_variant(expected:, variant:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::ColorVariant.web_awesome(variant: variant)
  end

  test "to_css: builds variants as we expect them" do
    assert_css_variant(expected: "wa-success", variant: :success)
    assert_css_variant(expected: "wa-success", variant: "success")
    assert_css_variant(expected: "wa-success", variant: :"wa-success")
    assert_css_variant(expected: "wa-success", variant: "wa-success")

    assert_css_variant(expected: "wa-custom", variant: "wa-custom")
    assert_css_variant(expected: "wa-custom", variant: "custom")
  end

  test "to_web_awesome: builds variants as we expect them" do
    assert_web_awesome_variant(expected: "success", variant: :success)
    assert_web_awesome_variant(expected: "success", variant: "success")
    assert_web_awesome_variant(expected: "success", variant: :"wa-success")
    assert_web_awesome_variant(expected: "success", variant: "wa-success")

    assert_web_awesome_variant(expected: "custom", variant: "wa-custom")
    assert_web_awesome_variant(expected: "custom", variant: "custom")
  end
end