# frozen_string_literal: true

require "test_helper"

class Practical::Views::WebAwesome::StyleUtility::AppearanceVariantTest < ActiveSupport::TestCase
  def assert_variants(expected:, variants:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::AppearanceVariant.css(variants: variants)
  end

  test "builds variants as we expect them" do
    assert_variants(expected: "wa-accent wa-filled", variants: "accent filled")
    assert_variants(expected: "wa-accent wa-filled", variants: ["accent", "filled"])
    assert_variants(expected: "wa-accent wa-filled", variants: [:accent, :filled])
    assert_variants(expected: "wa-accent", variants: [:accent])
    assert_variants(expected: "wa-filled", variants: [:filled])
    assert_variants(expected: "wa-accent", variants: [:"wa-accent"])
    assert_variants(expected: "wa-filled", variants: [:"wa-filled"])

    assert_variants(expected: "wa-accent", variants: ["wa-accent"])
    assert_variants(expected: "wa-filled", variants: ["wa-filled"])
    assert_variants(expected: "wa-accent wa-filled", variants: ["wa-accent", "filled"])
    assert_variants(expected: "wa-accent wa-filled", variants: "wa-accent wa-filled")
  end
end