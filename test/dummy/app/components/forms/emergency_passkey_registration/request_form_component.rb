# frozen_string_literal: true

class Forms::EmergencyPasskeyRegistration::RequestFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper
  attr_accessor :form, :url, :emergency_registration_class

  def initialize(form:, url:, emergency_registration_class:)
    @form = form
    @url = url
    @emergency_registration_class = emergency_registration_class
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: form,
      url: url,
      local: false,
      data: {
        type: :json
      },
      &block
    )
  end
end
