# frozen_string_literal: true

class Forms::Organization::MembershipFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper
  attr_accessor :form

  delegate :current_organization, to: :helpers

  def initialize(form:)
    @form = form
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: form,
      url: organization_membership_url(current_organization, form.membership),
      method: :patch,
      &block
    )
  end
end
