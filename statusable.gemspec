# frozen_string_literal: true

require_relative "lib/statusable/version"

Gem::Specification.new do |spec|
  spec.name = "statusable"
  spec.version = Statusable::VERSION
  spec.authors = ["Paul DobbinSchmaltz"]
  spec.email = ["p.dobbinschmaltz@icloud.com"]

  spec.summary = "Adds a `has_statuses` macro for defining common status-related ActiveRecord / Relation methods."
  spec.description = "Statusable adds a `has_statuses` macro for defining common status-related methods for use with ActiveRecord objects / Relations."
  spec.homepage = "https://github.com/pdobb/statusable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/pdobb/statusable/issues",
    "changelog_uri" => "https://github.com/pdobb/statusable/releases",
    "source_code_uri" => "https://github.com/pdobb/statusable",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) {
      Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
    }

  spec.add_dependency "rails", ">= 6"

  spec.add_development_dependency "gemwork"

  # Dummy Rails app dependencies.
  spec.add_development_dependency "puma"
  spec.add_development_dependency "sqlite3"
end
