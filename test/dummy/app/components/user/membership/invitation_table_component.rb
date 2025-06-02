# frozen_string_literal: true

class User::Membership::InvitationTableComponent < ApplicationComponent
  attr_accessor :membership_invitations
  delegate :current_user, :allowed_to?, to: :helpers

  def initialize(membership_invitations:)
    @membership_invitations = membership_invitations
  end
end
