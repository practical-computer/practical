# frozen_string_literal: true

module Practical::Test::Helpers::Administrator::TestHelpers
  def switch_to_admin_host
    host!(AppSettings.generate_uri(subdomain: "admin"))
  end
end