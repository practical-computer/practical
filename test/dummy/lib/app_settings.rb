# frozen_string_literal: true

class AppSettings
  def self.env_fetch(method_name:, key:)
    define_singleton_method(method_name){ ENV.fetch(key) }
  end

  env_fetch(method_name: :relying_party_origin, key: "RELYING_PARTY_ORIGIN")
  env_fetch(method_name: :default_host, key: "DEFAULT_HOST")
end