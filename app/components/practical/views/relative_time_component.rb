# frozen_string_literal: true

class Practical::Views::RelativeTimeComponent < ApplicationComponent
  attr_accessor :time

  def initialize(time:)
    @time = time
  end

  def call
    tag.wa_relative_time(helpers.time_ago_in_words(time), date: time.iso8601)
  end
end
