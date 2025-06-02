# frozen_string_literal: true

class Organization::Membership::TableComponent < ApplicationComponent
  attr_accessor :memberships
  delegate :current_organization, :allowed_to?, to: :helpers

  def initialize(memberships:)
    @memberships = memberships
  end
end
