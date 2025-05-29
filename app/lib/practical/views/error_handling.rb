module Practical::Views::ErrorHandling
  def self.build_error_json(model:, helpers:)
    return model.errors.map do |error|
      error_container_id = error_container_id(model: model, error: error, helpers: helpers)
      element_id = error_element_id(model: model, error: error, helpers: helpers)

      {
        container_id: error_container_id,
        element_to_invalidate_id: element_id,
        message: error.message,
        type: error.type
      }
    end
  end

  def self.error_container_id(model:, error:, helpers:)
    if error.options[:error_container_id].present?
      return error.options[:error_container_id]
    else
      attribute_name_parts = error.attribute.to_s.split(".")
      return helpers.field_id(model, *attribute_name_parts, :errors)
    end
  end

  def self.error_element_id(model:, error:, helpers:)
    if error.options[:element_id].present?
      return error.options[:element_id]
    else
      attribute_name_parts = error.attribute.to_s.split(".")
      return helpers.field_id(model, *attribute_name_parts)
    end
  end
end