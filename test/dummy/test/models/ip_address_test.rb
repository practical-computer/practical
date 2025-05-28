require "test_helper"

class IPAddressTest < ActiveSupport::TestCase
  include Practical::Test::Shared::Models::Utility::IPAddress

  def model_class
    IPAddress
  end

  def new_model_instance(address: Faker::Internet.ip_v6_address)
    IPAddress.new(address: address)
  end
end
