# frozen_string_literal: true

require "test_helper"

class UserAgentTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Models::Utility::UserAgent

  def model_class
    UserAgent
  end

  def new_model_instance(user_agent: Faker::Computer.stack)
    UserAgent.new(user_agent: user_agent)
  end
end
