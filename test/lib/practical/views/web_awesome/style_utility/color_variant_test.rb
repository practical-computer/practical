# frozen_string_literal: true

require "test_helper"

class Practical::Views::WebAwesome::StyleUtility::ColorVariantTest < ActiveSupport::TestCase
  def assert_variant(expected:, variant:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::ColorVariant.css(variant: variant)
  end

  test "builds variants as we expect them" do
    assert_variant(expected: "wa-success", variant: :success)
    assert_variant(expected: "wa-success", variant: "success")
    assert_variant(expected: "wa-success", variant: :"wa-success")
    assert_variant(expected: "wa-success", variant: "wa-success")

    assert_variant(expected: "wa-custom", variant: "wa-custom")
    assert_variant(expected: "wa-custom", variant: "custom")
  end
end