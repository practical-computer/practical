# frozen_string_literal: true

class Practical::Views::WebAwesome::StyleUtility::Size < Practical::Views::WebAwesome::StyleUtility::Base
  attr_accessor :size

  def initialize(size:)
    self.size = size.to_s
  end

  def to_css
    self.class.apply_css_prefix(self.class.css_from_alias(size: size))
  end

  def to_web_awesome
    return self.class.web_awesome_from_alias(size: size).to_s
  end

  def self.apply_css_prefix(value)
    return value if value.start_with?("wa-size")
    "wa-size-#{value}"
  end

  def self.web_awesome_from_alias(size:)
    case size.to_s.delete_prefix("wa-size-").to_sym
    when :s
      return :small
    when :m
      return :medium
    when :l
      return :large
    else
      return size.to_s.delete_prefix("wa-size-")
    end
  end

  def self.css_from_alias(size:)
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