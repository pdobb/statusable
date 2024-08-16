# frozen_string_literal: true

# Version: 20240815142345
class CreateCustomModels < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_models do |t|
      t.string :lifecycle_state, null: false, default: "Initializing", index: true

      t.timestamps
    end
  end
end
