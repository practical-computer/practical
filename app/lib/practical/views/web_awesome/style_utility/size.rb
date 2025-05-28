# frozen_string_literal: true

class Practical::Views::WebAwesome::StyleUtility::Size < Practical::Views::WebAwesome::StyleUtility::Base
  attr_accessor :size

  def initialize(size:)
    self.size = size.to_s
  end

  def to_css
    self.class.apply_css_prefix(self.class.from_alias(size: size))
  end

  def self.apply_css_prefix(value)
    return value if value.start_with?("wa-size")
    "wa-size-#{value}"
  end

  def self.from_alias(size:)
    case size.to_sym
    when :small
      return :s
    when :medium
      return :m
    when :large
      return :l
    else
      return size
    end
  end
end