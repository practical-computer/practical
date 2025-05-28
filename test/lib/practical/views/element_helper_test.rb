# frozen_string_literal: true

require "test_helper"

class Practical::Views::ElementHelperTest < ActiveSupport::TestCase
  class TestClass
    include Practical::Views::ElementHelper
  end

  def mix(default, new_value)
    TestClass.new.mix(default, new_value)
  end

  test "mix: nil + string" do
    output = mix({ class: nil }, { class: "a" })
    assert_equal({ class: "a" }, output)
  end

  test "mix: string + nil" do
    output = mix({ class: "a" }, { class: nil })
    assert_equal({ class: "a" }, output)
  end

  test "mix: array + nil" do
    output = mix({ class: ["foo", "bar"] }, { class: nil })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: array + array" do
    output = mix({ class: ["foo"] }, { class: ["bar"] })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: array + set" do
    output = mix({ class: ["foo"] }, { class: Set["bar"] })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: array + hash" do
    output = mix(
      { data: ["foo"] },
      { data: { controller: "bar" } },
    )

    assert_equal({ data: { controller: "bar" } }, output)
  end

  test "mix: array + string" do
    output = mix({ class: ["foo"] }, { class: "bar" })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: hash + hash" do
    output = mix(
      { data: { controller: "foo" } },
      { data: { controller: "bar" } },
    )

    assert_equal({ data: { controller: "foo bar" } }, output)
  end

  test "mix: string + array" do
    output = mix({ class: "foo" }, { class: ["bar"] })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: string + string" do
    output = mix({ class: "foo" }, { class: "bar" })
    assert_equal({ class: "foo bar" }, output)
  end

  test "mix: string + set" do
    output = mix({ class: "foo" }, { class: Set["bar"] })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: override" do
    output = mix({ class: "foo" }, { class!: "bar" })
    assert_equal({ class: "bar" }, output)
  end

  test "mix: set + set" do
    output = mix({ class: Set["foo"] }, { class: Set["bar"] })
    assert_equal output, { class: Set["foo", "bar"] }
  end

  test "mix: set + array" do
    output = mix({ class: Set["foo"] }, { class: ["bar"] })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "mix: set + string" do
    output = mix({ class: Set["foo"] }, { class: "bar" })
    assert_equal({ class: ["foo", "bar"] }, output)
  end

  test "single binding" do
    output = TestClass.new.grab(class: "foo")
    assert_equal "foo", output
  end

  test "multiple bindings" do
    output = TestClass.new.grab(class: "foo", if: "bar")
    assert_equal ["foo", "bar"], output
  end
end