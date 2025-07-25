# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in practical-framework.gemspec.
gemspec

gem "puma"

gem "sqlite3"

gem "dartsass-rails"
gem "jsbundling-rails"
gem "propshaft"

# Start debugger with binding.b [https://github.com/ruby/debug]
gem "debug", ">= 1.0.0"

gem "devise-passkeys"

gem "dotenv-rails", require: 'dotenv/load'
gem "view_component"

gem "flipper"
gem "flipper-active_record"

gem "action_policy"
gem "honeybadger"
gem "pagy"
gem "rubocop"

group :test do
  gem "capybara"
  gem 'capybara-lockstep'
  gem 'capybara-screenshot'
  gem "localhost"
  gem "simplecov"
  gem 'spy'
  gem 'timecop'
end

group :development, :test do
  gem "faker"
  gem 'rubocop-capybara', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem "rubocop-rails-omakase", require: false
  gem 'rubocop-rubycw', require: false
end
