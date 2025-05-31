# frozen_string_literal: true

class User::PasskeysTableComponent < ApplicationComponent
  attr_accessor :passkeys

  delegate :current_user, to: :helpers

  def initialize(passkeys:)
    @passkeys = passkeys
  end
end
