# frozen_string_literal: true

# Version: 20240815042345
class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.string :status, null: false, default: "Initializing", index: true

      t.timestamps
    end
  end
end
