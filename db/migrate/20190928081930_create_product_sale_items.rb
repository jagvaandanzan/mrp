class CreateProductSaleItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_items do |t|
      t.references :product_sale, foreign_key: true
      t.references :product, foreign_key: true
      t.references :product_feature_rel, foreign_key: true
      t.integer :quantity
      t.float :price
      t.float :sum_price, limit: 53

      t.timestamps
    end
  end
end
