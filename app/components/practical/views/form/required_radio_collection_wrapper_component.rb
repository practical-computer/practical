# frozen_string_literal: true

class Practical::Views::Form::RequiredRadioCollectionWrapperComponent < Practical::Views::BaseComponent
  attr_reader :f, :object_method, :options
  def initialize(f:, object_method:, options:)
    @f = f
    @object_method = object_method
    @options = options
  end

  def finalized_options
    mix({
      "fieldset": f.field_id(object_method),
      "field-name": f.field_name(object_method),
      "errors-element": f.field_id(object_method, :errors),
      "errors-element-aria": f.field_id(object_method, :errors_aria),
    }, options)
  end

  def call
    content_tag(:"required-radio-collection", content, **finalized_options)
  end
end
