# frozen_string_literal: true

class User::Membership::TableComponent < ApplicationComponent
  attr_accessor :memberships
  delegate :current_user, :allowed_to?, to: :helpers

  def initialize(memberships:)
    @memberships = memberships
  end
end
