# frozen_string_literal: true

module Practical::Views::ErrorResponse
  extend ActiveSupport::Concern

  def render_json_error(format:, model:)
    format.json do
      errors = Practical::Views::ErrorHandling.build_error_json(model: model, helpers: helpers)
      yield(errors) if block_given?
      render json: errors, status: :bad_request
    end
  end

  def render_html_error(action:, format:)
    format.html do
      yield  if block_given?
      render action, status: :bad_request
    end
  end

  def default_respond_to_model_validation_error(html_action:, model:)
    respond_to do |format|
      render_json_error(format: format, model: model)
      render_html_error(action: html_action, format: format)
    end
  end
end