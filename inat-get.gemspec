# frozen_string_literal: true

require_relative "lib/inat-get/info"

Gem::Specification.new do |spec|
  spec.name = "inat-get"
  spec.version = INat::Info::VERSION
  spec.authors = [INat::Info::AUTHOR]
  spec.email = [INat::Info::EMAIL]

  spec.summary = "Client for iNaturalist API."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = INat::Info::HOMEPAGE
  spec.license = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = INat::Info::SOURCE_URL

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ samples/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = ["inat-get"]
  spec.require_paths = ["lib"]

  spec.add_dependency "pg", "~> 1.5.9"
  spec.add_dependency "sequel", "~> 5.90.0"
  spec.add_dependency "tzinfo", "~> 2.0.6"
end
