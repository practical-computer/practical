# frozen_string_literal: true

class Forms::SignupFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper
  attr_accessor :model, :as, :url, :challenge_url, :credential_field_name

  def initialize(model:, as:, url:, challenge_url:, credential_field_name:)
    self.model = model
    self.as = as
    self.url = url
    self.challenge_url = challenge_url
    self.credential_field_name = credential_field_name
  end

  def form_id
    dom_id(model, :registration_form)
  end

  def generic_errors_id
    dom_id(model, :generic_errors)
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: model,
      as: as,
      url: url,
      local: false,
      id: form_id,
      data: {
        type: :json,
        challenge_url: challenge_url,
        credential_field_name: credential_field_name,
        register_passkey_form: true
      },
      &block
    )
  end
end
