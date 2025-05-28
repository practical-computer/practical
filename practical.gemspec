# frozen_string_literal: true

require_relative "lib/practical/version"

Gem::Specification.new do |spec|
  spec.name = "practical"
  spec.version = Practical::VERSION
  spec.authors = ["Thomas Cannon"]
  spec.email = ["tcannon00@gmail.com"]

  spec.summary = "The Practical Framework"
  spec.description = "The Ruby code for the Practical Framework"
  spec.homepage = "https://github.com/practical-computer/practical"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/practical-computer/practical"
  spec.metadata["changelog_uri"] = "https://github.com/practical-computer/practical/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
  spec.add_dependency "view_component"
  spec.add_dependency "loaf"
  spec.add_dependency "pagy"
  spec.add_dependency "honeybadger"
  spec.add_dependency "semantic_logger"
  spec.add_dependency "devise-passkeys"
  spec.add_dependency "shrine"
  spec.add_dependency "oaken"
  spec.add_dependency "action_policy"
end
