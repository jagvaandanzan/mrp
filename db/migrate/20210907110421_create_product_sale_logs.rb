class CreateProductSaleLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_logs do |t|
      t.references :operator, foreign_key: true
      t.references :o_product, foreign_key: {to_table: :products}
      t.references :product, foreign_key: true
      t.references :o_feature_item, foreign_key: {to_table: :product_feature_items}
      t.references :feature_item, foreign_key: {to_table: :product_feature_items}
      t.integer :o_quantity
      t.integer :quantity
      t.boolean :o_to_see
      t.boolean :to_see
      t.integer :o_p_discount
      t.integer :p_discount
      t.integer :o_discount
      t.integer :discount

      t.timestamps
    end
  end
end
