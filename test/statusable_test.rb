# frozen_string_literal: true

require "test_helper"

class StatusableTest < Minitest::Spec
  describe Statusable do
    it "has a VERSION" do
      value(Statusable::VERSION).wont_be_nil
    end
  end
end
