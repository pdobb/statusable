# frozen_string_literal: true

require "test_helper"

class StatusableTest < Minitest::Spec
  describe Statusable do
    it "has a VERSION" do
      _(Statusable::VERSION).wont_be_nil
    end
  end
end
