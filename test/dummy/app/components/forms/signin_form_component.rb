# frozen_string_literal: true

class Forms::SigninFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper

  def initialize(model:, as:, url:, challenge_url:, credential_field_name:)
    @model = model
    @as = as
    @url = url
    @challenge_url = challenge_url
    @credential_field_name = credential_field_name
  end

  def form_id
    dom_id(@model, :session_form)
  end

  def generic_errors_id
    dom_id(@model, :generic_errors)
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: @model,
      as: @as,
      url: @url,
      local: false,
      id: form_id,
      data: {
        type: :json,
        challenge_url: @challenge_url,
        credential_field_name: @credential_field_name,
        new_session_form: true
      },
      &block
    )
  end
end
