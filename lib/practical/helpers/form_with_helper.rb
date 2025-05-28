# frozen_string_literal: true

module Practical::Helpers::FormWithHelper
  def application_form_with(**options, &block)
    finalized_options = options.with_defaults(
      builder: ApplicationFormBuilder
    )
    practical_form_with(**finalized_options, &block)
  end
end
