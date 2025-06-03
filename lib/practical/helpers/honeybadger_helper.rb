# frozen_string_literal: true

module Practical::Helpers::HoneybadgerHelpers
  def honeybadger_js_configuration
    {
      "apiKey" => AppSettings.honeybadger_js_api_key,
      "environment" => AppSettings.app_env,
      "revision" => AppSettings.app_revision
    }
  end
end