class Practical::Test::SharedTestGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_shared_test
    template "shared_test.rb", File.join("app/lib/practical/test/shared/", "#{file_path}.rb")
  end
end
