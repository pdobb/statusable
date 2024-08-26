# frozen_string_literal: true

require "test_helper"

class Statusable::HasStatusesTest < Minitest::Spec
  describe Statusable::HasStatuses do
    describe "DEFAULT OPTIONS" do
      let(:model_klass) { DefaultModel }
      let(:table_name) { "default_models" }
      let(:new_model) { DefaultModel.new }
      let(:pending_model) { DefaultModel.new.set_status_pending! }
      let(:running_model) { DefaultModel.new.set_status_running! }
      let(:completed_model) { DefaultModel.new.set_status_completed! }
      let(:status_options_array) { %w[Pending Running Completed] }
      let(:humanized_statuses_list) { "Pending, Running, or Completed" }

      describe "Enumerators" do
        context ".status_pending" do
          it "returns Pending" do
            value(model_klass.status_pending).must_equal("Pending")
          end
        end

        context "#status_pending" do
          it "returns Pending" do
            value(new_model.status_pending).must_equal("Pending")
          end
        end

        context ".status_options" do
          it "returns the expected Array" do
            value(model_klass.status_options).must_equal(status_options_array)
          end
        end

        context "#status_options" do
          it "returns the expected Array" do
            value(new_model.status_options).must_equal(status_options_array)
          end
        end

        context ".humanized_statuses_list" do
          it "returns the expected String" do
            value(model_klass.humanized_statuses_list).must_equal(
              humanized_statuses_list)
          end
        end

        context "#humanized_statuses_list" do
          it "returns the expected String" do
            value(new_model.humanized_statuses_list).must_equal(
              humanized_statuses_list)
          end
        end
      end

      describe "Query Methods" do
        context ".for_status" do
          it "builds the expected query, given a String" do
            subject = model_klass.for_status("Pending")
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."status" = 'Pending'))
          end

          it "builds the expected query, given an Array of Strings" do
            subject = model_klass.for_status(%w[Pending Running])
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."status" IN ('Pending', 'Running')))
          end
        end

        context ".not_for_status" do
          it "builds the expected query, given a String" do
            subject = model_klass.not_for_status("Pending")
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."status" != 'Pending'))
          end

          it "builds the expected query, given an Array of Strings" do
            subject = model_klass.not_for_status(%w[Pending Running])
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."status" NOT IN ('Pending', 'Running')))
          end
        end

        context ".for_status_pending" do
          it "builds the expected query" do
            subject = model_klass.for_status_pending
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."status" = 'Pending'))
          end
        end

        context ".not_for_status_pending" do
          it "builds the expected query" do
            subject = model_klass.not_for_status_pending
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."status" != 'Pending'))
          end
        end

        context ".by_status_asc" do
          it "builds the expected query" do
            subject = model_klass.by_status_asc
            value(subject.to_sql).must_include(
              %(ORDER BY "#{table_name}"."status"))
          end
        end

        context ".by_status_desc" do
          it "builds the expected query" do
            subject = model_klass.by_status_desc
            value(subject.to_sql).must_include(
              %(ORDER BY "#{table_name}"."status" DESC))
          end
        end

        context ".group_by_status" do
          it "builds the expected query" do
            subject = model_klass.group_by_status
            value(subject.to_sql).must_include(
              %(GROUP BY "#{table_name}"."status"))
          end
        end
      end

      describe "Setters" do
        context "#set_status_running" do
          it "sets the status to Running" do
            pending_model.set_status_running
            value(pending_model.status).must_equal("Running")
          end
        end

        context "#set_status_running!" do
          it "sets the status to Running and saves the record" do
            pending_model.set_status_running!
            value(pending_model.status).must_equal("Running")
            value(pending_model.reload.status).must_equal("Running")
          end
        end
      end

      describe "Predicates" do
        context "#status?" do
          context "GIVEN a single status" do
            it "returns true, GIVEN a matching status" do
              value(pending_model.status?("Pending")).must_equal(true)
            end

            it "returns false, GIVEN a non-matching status" do
              value(pending_model.status?("Not Pending")).must_equal(false)
            end

            it "returns false, GIVEN nil" do
              value(pending_model.status?(nil)).must_equal(false)
            end
          end

          context "GIVEN an array of statuses" do
            it "returns true, GIVEN at least one matching status" do
              value(pending_model.status?(["Pending", "Not Pending"])).
                must_equal(true)
            end

            it "returns false, GIVEN no matching statuses" do
              value(pending_model.status?(["Not Pending", "Also Not Pending"])).
                must_equal(false)
            end

            it "returns false, GIVEN an empty Array" do
              value(pending_model.status?([])).
                must_equal(false)
            end
          end
        end

        context "#not_status?" do
          it "returns false, GIVEN a matching status" do
            value(pending_model.not_status?("Pending")).must_equal(false)
          end

          it "returns true, GIVEN a non-matching status" do
            value(pending_model.not_status?("Not Pending")).must_equal(true)
          end
        end

        context "#status_pending?" do
          it "returns true, GIVEN a pending status" do
            value(pending_model.status_pending?).must_equal(true)
          end

          it "returns false, GIVEN a non-pending status" do
            subject = [running_model, completed_model].sample
            value(subject.status_pending?).must_equal(false)
          end
        end

        context "#not_status_pending?" do
          it "returns false, GIVEN a pending status" do
            value(pending_model.not_status_pending?).must_equal(false)
          end

          it "returns true, GIVEN a non-pending status" do
            subject = [running_model, completed_model].sample
            value(subject.not_status_pending?).must_equal(true)
          end
        end
      end

      describe "Validations" do
        context "GIVEN Presence is not required" do
          subject { new_model }

          it "fails validation, GIVEN a blank status" do
            subject.status = nil
            subject.validate
            value(subject.errors[:status]).wont_include("can't be blank")
          end

          it "passes validation, GIVEN a status" do
            subject.set_status_pending.validate
            value(subject.errors[:status]).wont_include("can't be blank")
          end
        end

        context "GIVEN Inclusion is required" do
          subject { new_model }

          it "fails validation, GIVEN an invalid status" do
            subject.status = "INVALID STATUS"
            subject.validate
            value(subject.errors[:status]).must_include(
              "must be one of Pending, Running, or Completed")
          end

          it "passes validation, GIVEN a valid status" do
            subject.set_status_pending.validate
            value(subject.errors[:status]).wont_include(
              "must be one of Pending, Running, or Completed")
          end
        end
      end
    end

    describe "CUSTOM OPTIONS" do
      let(:model_klass) { CustomModel }
      let(:table_name) { "custom_models" }
      let(:new_model) { CustomModel.new }
      let(:pending_model) { CustomModel.new.set_lifecycle_state_pending! }
      let(:running_model) { CustomModel.new.set_lifecycle_state_running! }
      let(:completed_model) { CustomModel.new.set_lifecycle_state_completed! }
      let(:lifecycle_state_options_array) { %w[Pending Running Completed] }
      let(:humanized_lifecycle_states_list) { "Pending, Running, or Completed" }

      describe "Enumerators" do
        context ".lifecycle_state_pending" do
          it "returns Pending" do
            value(model_klass.lifecycle_state_pending).must_equal("Pending")
          end
        end

        context "#lifecycle_state_pending" do
          it "returns Pending" do
            value(new_model.lifecycle_state_pending).must_equal("Pending")
          end
        end

        context ".lifecycle_state_options" do
          it "returns the expected Array" do
            value(model_klass.lifecycle_state_options).must_equal(
              lifecycle_state_options_array)
          end
        end

        context "#lifecycle_state_options" do
          it "returns the expected Array" do
            value(new_model.lifecycle_state_options).must_equal(
              lifecycle_state_options_array)
          end
        end

        context ".humanized_lifecycle_states_list" do
          it "returns the expected String" do
            value(model_klass.humanized_lifecycle_states_list).must_equal(
              humanized_lifecycle_states_list)
          end
        end

        context "#humanized_lifecycle_states_list" do
          it "returns the expected String" do
            value(new_model.humanized_lifecycle_states_list).must_equal(
              humanized_lifecycle_states_list)
          end
        end
      end

      describe "Query Methods" do
        context ".for_lifecycle_state" do
          it "builds the expected query, given a String" do
            subject = model_klass.for_lifecycle_state("Pending")
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."lifecycle_state" = 'Pending'))
          end

          # rubocop:disable Layout/LineLength
          it "builds the expected query, given an Array of Strings" do
            subject = model_klass.for_lifecycle_state(%w[Pending Running])
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."lifecycle_state" IN ('Pending', 'Running')))
          end
          # rubocop:enable Layout/LineLength
        end

        context ".not_for_lifecycle_state" do
          it "builds the expected query, given a String" do
            subject = model_klass.not_for_lifecycle_state("Pending")
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."lifecycle_state" != 'Pending'))
          end

          # rubocop:disable Layout/LineLength
          it "builds the expected query, given an Array of Strings" do
            subject = model_klass.not_for_lifecycle_state(%w[Pending Running])
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."lifecycle_state" NOT IN ('Pending', 'Running')))
          end
          # rubocop:enable Layout/LineLength
        end

        context ".for_lifecycle_state_pending" do
          it "builds the expected query" do
            subject = model_klass.for_lifecycle_state_pending
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."lifecycle_state" = 'Pending'))
          end
        end

        context ".not_for_lifecycle_state_pending" do
          it "builds the expected query" do
            subject = model_klass.not_for_lifecycle_state_pending
            value(subject.to_sql).must_include(
              %(WHERE "#{table_name}"."lifecycle_state" != 'Pending'))
          end
        end

        context ".by_lifecycle_state_asc" do
          it "builds the expected query" do
            subject = model_klass.by_lifecycle_state_asc
            value(subject.to_sql).must_include(
              %(ORDER BY "#{table_name}"."lifecycle_state"))
          end
        end

        context ".by_lifecycle_state_desc" do
          it "builds the expected query" do
            subject = model_klass.by_lifecycle_state_desc
            value(subject.to_sql).must_include(
              %(ORDER BY "#{table_name}"."lifecycle_state" DESC))
          end
        end

        context ".group_by_lifecycle_state" do
          it "builds the expected query" do
            subject = model_klass.group_by_lifecycle_state
            value(subject.to_sql).must_include(
              %(GROUP BY "#{table_name}"."lifecycle_state"))
          end
        end
      end

      describe "Setters" do
        context "#set_lifecycle_state_running" do
          it "sets the lifecycle_state to Running" do
            pending_model.set_lifecycle_state_running
            value(pending_model.lifecycle_state).must_equal("Running")
          end
        end

        context "#set_lifecycle_state_running!" do
          it "sets the lifecycle_state to Running and saves the record" do
            pending_model.set_lifecycle_state_running!
            value(pending_model.lifecycle_state).must_equal("Running")
            value(pending_model.reload.lifecycle_state).must_equal("Running")
          end
        end
      end

      describe "Predicates" do
        context "#lifecycle_state?" do
          it "returns true, GIVEN a matching lifecycle_state" do
            value(pending_model.lifecycle_state?("Pending")).must_equal(true)
          end

          it "returns false, GIVEN a non-matching lifecycle_state" do
            value(pending_model.lifecycle_state?("Not Pending")).must_equal(
              false)
          end
        end

        context "#not_lifecycle_state?" do
          it "returns false, GIVEN a matching lifecycle_state" do
            value(pending_model.not_lifecycle_state?("Pending")).must_equal(
              false)
          end

          it "returns true, GIVEN a non-matching lifecycle_state" do
            value(pending_model.not_lifecycle_state?("Not Pending")).must_equal(
              true)
          end
        end

        context "#lifecycle_state_pending?" do
          it "returns true, GIVEN a pending lifecycle_state" do
            value(pending_model.lifecycle_state_pending?).must_equal(true)
          end

          it "returns false, GIVEN a non-pending lifecycle_state" do
            subject = [running_model, completed_model].sample
            value(subject.lifecycle_state_pending?).must_equal(false)
          end
        end

        context "#not_lifecycle_state_pending?" do
          it "returns false, GIVEN a pending lifecycle_state" do
            value(pending_model.not_lifecycle_state_pending?).must_equal(false)
          end

          it "returns true, GIVEN a non-pending lifecycle_state" do
            subject = [running_model, completed_model].sample
            value(subject.not_lifecycle_state_pending?).must_equal(true)
          end
        end
      end

      describe "Validations" do
        context "GIVEN Presence is required" do
          subject { new_model }

          it "fails validation, GIVEN a blank lifecycle_state" do
            subject.lifecycle_state = nil
            subject.validate
            value(subject.errors[:lifecycle_state]).must_include(
              "can't be blank")
          end

          it "passes validation, GIVEN a lifecycle_state" do
            subject.set_lifecycle_state_pending.validate
            value(subject.errors[:lifecycle_state]).wont_include(
              "can't be blank")
          end
        end

        context "GIVEN Inclusion is not required" do
          subject { new_model }

          it "passes validation, GIVEN an invalid lifecycle_state" do
            subject.lifecycle_state = "INVALID STATUS"
            subject.validate
            value(subject.errors[:lifecycle_state]).wont_include(
              "must be one of Pending, Running, or Completed")
          end

          it "passes validation, GIVEN a valid lifecycle_state" do
            subject.set_lifecycle_state_pending.validate
            value(subject.errors[:lifecycle_state]).wont_include(
              "must be one of Pending, Running, or Completed")
          end
        end
      end
    end
  end
end
