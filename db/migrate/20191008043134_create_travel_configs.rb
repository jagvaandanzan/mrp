class CreateTravelConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :travel_configs do |t|
      t.references :user, foreign_key: true
      t.integer :max_travel
      t.integer :waiting_time

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
