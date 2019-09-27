class CreateLocationTravels < ActiveRecord::Migration[5.2]
  def change
    create_table :location_travels do |t|
      t.references :location_from
      t.references :location_to
      t.integer :distance
      t.integer :duration

      t.timestamps
    end

    add_foreign_key :location_travels, :locations, column: :location_from_id, primary_key: :id
    add_foreign_key :location_travels, :locations, column: :location_to_id, primary_key: :id

  end
end
