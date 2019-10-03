class CreateProductSaleItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_items do |t|
      t.references :product_sale
      t.references :product
      t.references :product_feature_rel
      t.float :quantity
      t.float :price
      t.float :bonus

      t.timestamps
    end
  end
end
