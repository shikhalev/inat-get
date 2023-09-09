# frozen_string_literal: true

require_relative "lib/inat/get/version"

Gem::Specification.new do |spec|
  spec.name = "inat-get"
  spec.version = INat::Get::VERSION
  spec.authors = ["Ivan Shikhalev"]
  spec.email = ["shikhalev@gmail.com"]

  spec.summary = "Client for iNaturalist API."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/shikhalev/inat-get"
  spec.license = "GPL-3.0"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shikhalev/inat-get"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = ['inat-get']
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
