# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "gemwork/test/support/simplecov"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths =
  [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths =
    [File.expand_path("fixtures", __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths =
    ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path =
    "#{File.expand_path("fixtures", __dir__)}/files"

  ActiveSupport::TestCase.fixtures(:all)
end

require "minitest/autorun"

# require "gemwork/test/support/much_stub"
require "gemwork/test/support/reporters"
require "gemwork/test/support/spec_dsl"

require "much-stub"

# Augment the existing Minitest::Spec class.
class Minitest::Spec
  after do
    MuchStub.unstub!
  end
end
