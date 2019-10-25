class CreateProductFeatureRels < ActiveRecord::Migration[5.2]
  def change
    create_table :product_feature_rels do |t|
      t.references :product, foreign_key: true
      t.float :sale_price, limit: 53
      t.float :discount_price, limit: 53
      t.string :barcode

      t.timestamps
    end
  end
end
