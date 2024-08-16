class CustomModel < ApplicationRecord
  has_statuses(%w[
      Pending
      Running
      Completed
    ],
    col_name: "lifecycle_state",
    validate_presence: true,
    validate_inclusion: false)
end
