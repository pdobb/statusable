class DefaultModel < ApplicationRecord
  has_statuses(%w[
      Pending
      Running
      Completed
    ])
end
