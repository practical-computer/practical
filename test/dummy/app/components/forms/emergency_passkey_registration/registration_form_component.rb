# frozen_string_literal: true

class Forms::EmergencyPasskeyRegistration::RegistrationFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper
  attr_accessor :form, :url, :challenge_url

  def initialize(form:, url:, challenge_url:)
    @form = form
    @url = url
    @challenge_url = challenge_url
  end

  def generic_errors_id
    dom_id(form, :generic_errors)
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: form,
      url: url,
      method: :patch,
      local: false,
      data: {
        type: :json,
        challenge_url: challenge_url,
        credential_field_name: field_name(form.model_name.param_key, :passkey_credential),
        register_passkey_form: true
      },
      &block
    )
  end
end
