# frozen_string_literal: true

class Forms::User::ProfileFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper

  attr_accessor :user
  def initialize(user:)
    @user = user
  end

  def form_id
    dom_id(user, :registration_form)
  end

  def generic_errors_id
    dom_id(user, :generic_errors)
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: user,
      as: :user,
      url: helpers.registration_path(user),
      local: false,
      id: form_id,
      data: {
        type: :json,
        reauthentication_challenge_url: new_user_reauthentication_challenge_url,
        reauthentication_token_url: user_reauthentication_url,
        reauthentication_token_field_name: field_name(:user, :reauthentication_token)
      },
      &block
    )
  end
end
