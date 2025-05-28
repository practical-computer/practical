# frozen_string_literal: true

class Practical::Views::WebAwesome::StyleUtility::AppearanceVariant < Practical::Views::WebAwesome::StyleUtility::Base
  attr_accessor :variants

  def initialize(variants:)
    if variants.kind_of?(Array)
      variants = variants.map(&:to_s)
    else
      variants = variants.to_s.split(" ")
    end

    self.variants = Array.wrap(variants)
  end

  def to_css
    ApplicationController.helpers.class_names(variants.map{|variant| self.class.apply_css_prefix(variant) })
  end
end