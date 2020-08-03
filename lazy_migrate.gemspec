# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lazy_migrate/version"

Gem::Specification.new do |spec|
  spec.name          = "lazy_migrate"
  spec.version       = LazyMigrate::VERSION
  spec.authors       = ["Jesse Duffield"]
  spec.email         = ["jessedduffield@gmail.com"]

  spec.summary       = 'A little terminal UI for managing schema migrations'
  spec.description   = 'lazy_migrate lets you easily see which migrations have and have not been run, and makes it easy to up/down/migrate/rollback your migrations through a terminal UI. You can even bump migration versions in the event that you\'ve just pulled master and somebody else merged their migration before yours.'
  spec.homepage      = "https://github.com/jesseduffield/lazy_migrate"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin/exe"
  spec.executables   = ['lazy_migrate']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency 'tty-prompt', '~> 0.22.0'
end
