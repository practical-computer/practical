# frozen_string_literal: true

class Practical::Views::Form::FieldErrorsComponent < Practical::Views::BaseComponent
  attr_reader :f, :object_method, :options

  def initialize(f:, object_method:, options:)
    @f = f
    @object_method = object_method
    @options = options
  end

  def call
    id = f.field_errors_id(object_method)
    classes = ["error-section", "wa-callout", "wa-danger"]
    errors = f.errors_for(object_method)

    if errors.blank?
      classes << ["no-server-errors"]
      errors = []
    end

    finalized_options = mix({id: id, class: classes, data: {'pf-error-container': true}}, options)

    return label(object_method, nil, finalized_options) {
      render Practical::Views::Form::ErrorListComponent.new(errors: errors)
    }
  end
end
