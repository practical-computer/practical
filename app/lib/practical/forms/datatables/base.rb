# frozen_string_literal: true

module Practical::Forms::Datatables::Base
  extend ActiveSupport::Concern

  included do
    attr_accessor :sort_key, :sort_direction, :filters, :sanitized

    before_validation :normalize_sort_key_and_direction
    validate :matches_schema?
  end

  def initialize(attributes = {})
    super
    self.sanitize!
    if self.filters.present?
      self.filters = self.class.filter_class.new(self.filters)
    end
  end

  def sanitized?
    return self.sanitized == true
  end

  def payload
    {
      sort_key: sort_key,
      sort_direction: sort_direction,
      filters: filters.to_h,
    }
  end

  def merged_payload(filters: nil, sort_key: nil, sort_direction: nil)
    result = payload
    result[:filters] ||= {}
    if filters.present?
      result[:filters].merge!(filters)
    end

    result[:sort_key] = sort_key if sort_key.present?
    result[:sort_direction] = sort_direction if sort_direction.present?

    return result
  end

  def sanitize!
    validate!
    self.sanitized = true
  rescue ActiveModel::ValidationError
    self.attributes = self.class.default_payload
    self.sanitized = true
    self.errors.clear
    self.validate!
  end

  def sort_direction_for(key:)
    return nil unless key.downcase.strip == self.sort_key.downcase.strip
    return sort_direction
  end

  def inverted_sort_direction_for(key:)
    return "asc" unless key.downcase.strip == self.sort_key.downcase.strip
    case sort_direction
    when "asc"
      "desc"
    else
      "asc"
    end
  end

  def normalize_sort_key_and_direction
    self.sort_key = sort_key.to_s.downcase.strip
    self.sort_direction = sort_direction.to_s.downcase.strip
  end

  def matches_schema?
    return if self.class.schema.validate?(payload)
    errors.add(:base, :payload_does_not_match_schema)
  end
end