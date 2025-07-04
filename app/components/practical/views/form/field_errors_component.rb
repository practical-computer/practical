# frozen_string_literal: true

class Practical::Views::Form::FieldErrorsComponent < Practical::Views::BaseComponent
  attr_reader :f, :object_method, :multiple_errors_blurb, :options

  def initialize(f:, object_method:, multiple_errors_blurb:, options:)
    @f = f
    @object_method = object_method
    @multiple_errors_blurb = multiple_errors_blurb
    @options = options
  end

  def errors
    f.errors_for(object_method) || []
  end

  def finalized_options
    id = f.field_errors_id(object_method)
    classes = ["error-section"]

    if errors.blank?
      classes << ["no-server-errors"]
    end

    return mix({
      id: id,
      class: classes,
      data: {'pf-error-container': true}
    }, options)
  end
end
