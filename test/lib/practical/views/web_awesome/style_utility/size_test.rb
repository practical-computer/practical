# frozen_string_literal: true

require "test_helper"

class Practical::Views::WebAwesome::StyleUtility::SizeVariantTest < ActiveSupport::TestCase
  def assert_size(expected:, size:)
    assert_equal expected, Practical::Views::WebAwesome::StyleUtility::Size.css(size: size)
  end

  test "builds sizes as we expect them" do
    assert_size(expected: "wa-size-s", size: :small)
    assert_size(expected: "wa-size-s", size: "small")
    assert_size(expected: "wa-size-s", size: :"wa-size-s")

    assert_size(expected: "wa-size-m", size: :medium)
    assert_size(expected: "wa-size-m", size: "medium")
    assert_size(expected: "wa-size-m", size: :"wa-size-m")

    assert_size(expected: "wa-size-l", size: :large)
    assert_size(expected: "wa-size-l", size: "large")
    assert_size(expected: "wa-size-l", size: :"wa-size-l")

    assert_size(expected: "wa-size-custom", size: :custom)
    assert_size(expected: "wa-size-custom", size: "custom")
    assert_size(expected: "wa-size-custom", size: :"wa-size-custom")
  end
end