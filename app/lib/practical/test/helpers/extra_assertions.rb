# frozen_string_literal: true

module Practical::Test::Helpers::ExtraAssertions
  def assert_equal_set(expected, actual)
    assert_equal Array.wrap(expected).to_set, Array.wrap(actual).to_set
  end
end