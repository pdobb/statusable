class Job < ApplicationRecord
  has_statuses(%w[
      Pending
      Running
      Completed
    ],
    col_name: "status",
    validate_presence: true,
    validate_inclusion: true)
end
