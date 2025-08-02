# frozen_string_literal: true

class Practical::Views::Form::InputComponent < Practical::Views::BaseComponent
  attr_accessor :f, :object_method, :label_options

  renders_one :label
  renders_one :field

  def initialize(f:, object_method:, label_options: {})
    self.f = f
    self.object_method = object_method
    self.label_options = label_options
  end

  def field_errors_id
    f.field_errors_id(object_method)
  end

  def field_options(**options)
    mix({
      "aria-describedby": field_errors_id,
      "data": {"pf-initial-load-errors": f.errors_for(object_method)&.any? }
    }, options)
  end
end
