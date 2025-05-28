# frozen_string_literal: true

module Practical::Test::Helpers::SpyAssertions
  def assert_times_called(spy:, times:)
    assert_equal times, spy.calls.count
  end
end
