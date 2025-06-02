# frozen_string_literal: true

class Forms::Organization::MembershipInvitationFormComponent < ApplicationComponent
  include Practical::Views::FormWrapper
  attr_accessor :form

  delegate :current_organization, to: :helpers

  def initialize(form:)
    @form = form
  end

  def form_wrapper(&block)
    wrapped_form_with(
      model: form,
      url: organization_memberships_url(current_organization),
      &block
    )
  end
end
