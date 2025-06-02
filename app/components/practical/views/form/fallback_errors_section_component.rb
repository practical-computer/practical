# frozen_string_literal: true

class Practical::Views::Form::FallbackErrorsSectionComponent < Practical::Views::BaseComponent
  attr_reader :f, :id, :blurb
  def initialize(f:, id:, blurb:, options:)
    @f = f
    @id = id
    @blurb = blurb
    @options = options
  end

  def finalized_options
    mix({
      class: ["error-section", "fallback-error-section", "wa-callout", "wa-danger"],
      id: id
    }, @options)
  end

  def remaining_errors
    return [] if f.object.try(:errors).blank?
    return f.object.errors.reject{|error| error.options[:has_been_rendered] }
  end
end
