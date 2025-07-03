# frozen_string_literal: true

require "test_helper"

class Practical::Views::WebAwesome::StyleUtility::AppearanceVariantTest < ActiveSupport::TestCase
  def assert_css_variants(expected:, variants:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::AppearanceVariant.css(variants: variants)
  end

  def assert_web_awesome_variants(expected:, variants:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::AppearanceVariant.web_awesome(variants: variants)
  end

  test "to_css: builds variants as we expect them" do
    assert_css_variants(expected: "wa-accent wa-filled", variants: "accent filled")
    assert_css_variants(expected: "wa-accent wa-filled", variants: ["accent", "filled"])
    assert_css_variants(expected: "wa-accent wa-filled", variants: [:accent, :filled])
    assert_css_variants(expected: "wa-accent", variants: [:accent])
    assert_css_variants(expected: "wa-filled", variants: [:filled])
    assert_css_variants(expected: "wa-accent", variants: [:"wa-accent"])
    assert_css_variants(expected: "wa-filled", variants: [:"wa-filled"])

    assert_css_variants(expected: "wa-accent", variants: ["wa-accent"])
    assert_css_variants(expected: "wa-filled", variants: ["wa-filled"])
    assert_css_variants(expected: "wa-accent wa-filled", variants: ["wa-accent", "filled"])
    assert_css_variants(expected: "wa-accent wa-filled", variants: "wa-accent wa-filled")
  end

  test "to_web_awesome: builds variants as we expect them" do
    assert_web_awesome_variants(expected: "accent filled", variants: "accent filled")
    assert_web_awesome_variants(expected: "accent filled", variants: ["accent", "filled"])
    assert_web_awesome_variants(expected: "accent filled", variants: [:accent, :filled])
    assert_web_awesome_variants(expected: "accent", variants: [:accent])
    assert_web_awesome_variants(expected: "filled", variants: [:filled])
    assert_web_awesome_variants(expected: "accent", variants: [:"wa-accent"])
    assert_web_awesome_variants(expected: "filled", variants: [:"wa-filled"])

    assert_web_awesome_variants(expected: "accent", variants: ["wa-accent"])
    assert_web_awesome_variants(expected: "filled", variants: ["wa-filled"])
    assert_web_awesome_variants(expected: "accent filled", variants: ["wa-accent", "filled"])
    assert_web_awesome_variants(expected: "accent filled", variants: "wa-accent wa-filled")
  end
end