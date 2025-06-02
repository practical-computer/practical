# frozen_string_literal: true

namespace :utility do
  desc "Track the deployment"
  task track_deployment: :environment do
    Honeybadger.track_deployment(
      environment: AppSettings.app_env,
      revision: AppSettings.app_revision,
      local_username: "rake",
      repository: "git@github.com:practical-computer/app_repo.git"
    )

    HTTPX.get("https://api.honeybadger.io/v1/deploys", params: {
      "deploy[environment]"=> AppSettings.app_env,
      "deploy[local_username]" => "rake",
      "deploy[revision]" => AppSettings.app_revision,
      "api_key" => AppSettings.honeybadger_js_api_key
    })
  end
end
