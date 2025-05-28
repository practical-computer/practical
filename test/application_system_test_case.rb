# frozen_string_literal: true

require "test_helper"
require 'capybara-screenshot/minitest'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Practical::Test::Helpers::System::Assertions
  include Practical::Test::Helpers::Passkey::TestHelper
  include Practical::Test::Helpers::Passkey::System::RackTest
  include Practical::Test::Helpers::System::CapybaraPrep

  driven_by :rack_test
end


class SlowBrowserSystemTestCase < ApplicationSystemTestCase
  include Practical::Test::Helpers::Passkey::System::Selenium

  setup do
    default_uri = URI.parse("https://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}")
    Spy.on(AppSettings, relying_party_origin: default_uri.to_s)
    Spy.on_instance_method(ActionController::Base, allow_forgery_protection: true)
  end

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400] do |options|
    options.accept_insecure_certs = true
    if ENV.has_key?("HEADLESS_TESTS")
      options.args << "--headless=new"
    else
      options.args << "--auto-open-devtools-for-tabs"
    end
  end
end
