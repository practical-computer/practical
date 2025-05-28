# frozen_string_literal: true

module Practical::Views::FormWrapper
  extend ActiveSupport::Concern

  def generic_errors_id
    dom_id(form, :generic_errors)
  end

  def wrapped_form_with(**options, &block)
    finalized_options = mix({
      html: {
        "aria-describedby": generic_errors_id,
      }
    }, options)
    helpers.application_form_with(
      **finalized_options,
      &block
    )
  end
end