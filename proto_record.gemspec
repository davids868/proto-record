# frozen_string_literal: true

require_relative "lib/proto_record/version"

Gem::Specification.new do |spec|
  spec.name          = "proto_record"
  spec.version       = ProtoRecord::VERSION
  spec.authors       = ["David Sapiro"]
  spec.email         = ["david.sapiro@gmail.com"]

  spec.summary       = "Transforms ActiveRecord object to Protocol Buffer messages"
  # spec.description   = "TODO: Write a longer description or delete this line."
  spec.homepage      = "https://github.com/davids868/proto-record"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rake", "~> 13.0"

  spec.add_development_dependency "activerecord", "~> 5.0"
  spec.add_development_dependency "grpc", "~> 1.35.0"
  spec.add_development_dependency "grpc-tools", "~> 1.35.0"
  spec.add_development_dependency "pry", "~> 0.13.1"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "sqlite3", "~> 1.4"
end
