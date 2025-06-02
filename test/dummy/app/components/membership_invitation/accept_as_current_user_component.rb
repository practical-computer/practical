# frozen_string_literal: true

class MembershipInvitation::AcceptAsCurrentUserComponent < ApplicationComponent
  attr_accessor :membership_invitation
  delegate :current_user, to: :helpers

  def initialize(membership_invitation:)
    @membership_invitation = membership_invitation
  end
end
