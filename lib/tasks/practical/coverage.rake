# frozen_string_literal: true

namespace :coverage do
  desc "Collates all result sets generated by the different test runners"
  task :report do
    require 'simplecov'
    require "simplecov_json_formatter"

    SimpleCov.collate Dir["coverage_results/.resultset-*.json"] do
      formatter SimpleCov::Formatter::MultiFormatter.new(
        [
          SimpleCov::Formatter::SimpleFormatter,
          SimpleCov::Formatter::HTMLFormatter,
          SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
        ]
      )
    end
  end
end