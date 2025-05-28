# frozen_string_literal: true

class Practical::Test::HelperGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_helper
    template "helper.rb", File.join("app/lib/practical/test/helpers", "#{file_path}.rb")
  end
end
