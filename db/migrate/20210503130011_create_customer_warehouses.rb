class CreateCustomerWarehouses < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_warehouses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :mo_start
      t.integer :mo_end
      t.integer :tu_start
      t.integer :tu_end
      t.integer :we_start
      t.integer :we_end
      t.integer :th_start
      t.integer :th_end
      t.integer :fr_start
      t.integer :fr_end
      t.integer :sa_start
      t.integer :sa_end
      t.integer :su_start
      t.integer :su_end
      t.decimal :latitude, precision: 15, scale: 10
      t.decimal :longitude, precision: 15, scale: 10
      t.timestamps
    end

    add_reference :product_feature_items, :customer_warehouse, foreign_key: true, after: 'c_name'
  end
end
