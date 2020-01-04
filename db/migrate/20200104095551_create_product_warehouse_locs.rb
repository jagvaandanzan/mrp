class CreateProductWarehouseLocs < ActiveRecord::Migration[5.2]
  def change
    create_table :product_warehouse_locs do |t|
      t.references :salesman_travel, foreign_key: true
      t.integer :queue
      t.references :product, foreign_key: true
      t.references :location, foreign_key: {to_table: :product_locations}
      t.references :feature_item, foreign_key: {to_table: :product_feature_items}
      t.references :feature_rel, foreign_key: {to_table: :product_feature_rels}
      t.integer :quantity
      t.datetime :load_at

      t.timestamps
    end
  end
end
