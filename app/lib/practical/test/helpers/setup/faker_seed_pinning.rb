# frozen_string_literal: true

module Practical::Test::Helpers::Setup::FakerSeedPinning
  def before_setup
    super
    Faker::Config.random = Random.new(Minitest.seed)
  end
end