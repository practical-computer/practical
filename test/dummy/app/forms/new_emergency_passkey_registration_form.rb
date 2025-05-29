# frozen_string_literal: true

class NewEmergencyPasskeyRegistrationForm
  include ActiveModel::API

  attr_accessor :email
  validates :email, presence: true, allow_blank: false
end
