class CreateProductSupplyFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :product_supply_features do |t|
      t.references :order_item, null: false, foreign_key: {to_table: :product_supply_order_items}
      t.references :feature_item, null: false, foreign_key: {to_table: :product_feature_items}
      t.integer :quantity
      t.float :price, limit: 53
      t.float :sum_price, limit: 53
      t.float :sum_tug, limit: 53
      t.string :note

      t.timestamps
    end
  end
end
