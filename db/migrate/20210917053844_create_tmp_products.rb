class CreateTmpProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :tmp_products do |t|
      t.string :name
      t.string :feature
      t.string :barcode
      t.integer :balance
      t.integer :price
      t.integer :serial_id
      t.string :location

      t.timestamps
    end
  end
end