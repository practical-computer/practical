# frozen_string_literal: true

require "test_helper"

class Practical::Views::WebAwesome::StyleUtility::SizeVariantTest < ActiveSupport::TestCase
  def assert_css_variant(expected:, size:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::Size.css(size: size)
  end

  def assert_web_awesome_variant(expected:, size:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::Size.web_awesome(size: size)
  end

  test "to_css: builds sizes as we expect them" do
    assert_css_variant(expected: "wa-size-s", size: :small)
    assert_css_variant(expected: "wa-size-s", size: "small")
    assert_css_variant(expected: "wa-size-s", size: :"wa-size-s")

    assert_css_variant(expected: "wa-size-m", size: :medium)
    assert_css_variant(expected: "wa-size-m", size: "medium")
    assert_css_variant(expected: "wa-size-m", size: :"wa-size-m")

    assert_css_variant(expected: "wa-size-l", size: :large)
    assert_css_variant(expected: "wa-size-l", size: "large")
    assert_css_variant(expected: "wa-size-l", size: :"wa-size-l")

    assert_css_variant(expected: "wa-size-custom", size: :custom)
    assert_css_variant(expected: "wa-size-custom", size: "custom")
    assert_css_variant(expected: "wa-size-custom", size: :"wa-size-custom")
  end

  test "to_web_awesome: builds sizes as we expect them" do
    assert_web_awesome_variant(expected: "small", size: :small)
    assert_web_awesome_variant(expected: "small", size: "small")
    assert_web_awesome_variant(expected: "small", size: :"wa-size-s")

    assert_web_awesome_variant(expected: "medium", size: :medium)
    assert_web_awesome_variant(expected: "medium", size: "medium")
    assert_web_awesome_variant(expected: "medium", size: :"wa-size-m")

    assert_web_awesome_variant(expected: "large", size: :large)
    assert_web_awesome_variant(expected: "large", size: "large")
    assert_web_awesome_variant(expected: "large", size: :"wa-size-l")

    assert_web_awesome_variant(expected: "custom", size: :custom)
    assert_web_awesome_variant(expected: "custom", size: "custom")
    assert_web_awesome_variant(expected: "custom", size: :"wa-size-custom")
  end
end