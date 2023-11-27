# frozen_string_literal: true

require "test_helper"

class StatusableTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Statusable::VERSION
  end
end
