class CreateManufacturers < ActiveRecord::Migration[5.2]
  def change
    create_table :manufacturers do |t|
      t.integer :queue, default: 1
      t.string :country

      t.timestamps
    end
  end
end
