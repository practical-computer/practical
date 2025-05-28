# frozen_string_literal: true

class Practical::Views::IconComponent < Practical::Views::BaseComponent
  include ActiveModel::Serializers::JSON

  attr_accessor :name, :family, :variant, :fixed_width, :label, :options

  def attributes=(hash)
    hash.each do |key, value|
      public_send("#{key}=", value)
    end
  end

  def attributes
    { "name" => nil, "family" => nil, "variant" => nil, "fixed_width" => nil, "label" => nil, "options" => nil }
  end

  def initialize(name:, family:, variant: nil, fixed_width: true, label: nil, options: {})
    self.name = name
    self.family = family
    self.variant = variant
    self.fixed_width = fixed_width
    self.label = label
    self.options = options
  end

  def call
    tag.wa_icon(**mix({
      "name": name,
      "family": family,
      "variant": variant,
      "fixed-width": fixed_width,
      "label": label
    }, options))
  end
end
