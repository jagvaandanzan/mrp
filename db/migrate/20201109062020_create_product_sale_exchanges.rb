class CreateProductSaleExchanges < ActiveRecord::Migration[6.0]
  def change
    create_table :product_sale_exchanges do |t|
      t.references :product_sale, null: false, foreign_key: true
      t.integer :e_type
      t.references :exchange, foreign_key: {to_table: :product_sale_exchanges}
      t.references :product, null: false, foreign_key: true
      t.references :feature_item, foreign_key: {to_table: :product_feature_items}
      t.integer :quantity
      t.float :price
      t.float :sum_price, limit: 53
      t.references :operator, foreign_key: true
      t.timestamps
    end
  end
end
