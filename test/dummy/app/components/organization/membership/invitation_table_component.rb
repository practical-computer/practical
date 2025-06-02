# frozen_string_literal: true

class Organization::Membership::InvitationTableComponent < ApplicationComponent
  attr_accessor :membership_invitations
  delegate :current_organization, :allowed_to?, to: :helpers

  def initialize(membership_invitations:)
    @membership_invitations = membership_invitations
  end
end
