class CreateProductLocationBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :product_location_balances do |t|
      t.references :product_location, null: false, foreign_key: true
      t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
      t.references :income_item, foreign_key: {to_table: :product_income_items}
      t.references :income_location, foreign_key: {to_table: :product_income_locations}
      t.references :travel, foreign_key: {to_table: :salesman_travels}
      t.references :warehouse_loc, foreign_key: {to_table: :product_warehouse_locs}
      t.integer :quantity

      t.timestamps
    end
    add_column :product_feature_items, :barcode, :string, after: 'same_item_id'
  end
end
