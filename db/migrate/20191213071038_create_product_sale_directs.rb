class CreateProductSaleDirects < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_directs do |t|
      t.references :salesman, foreign_key: true
      t.references :product, foreign_key: true
      t.references :feature_rel, foreign_key: {to_table: :product_feature_rels}
      t.references :feature_item, foreign_key: {to_table: :product_feature_items}
      t.integer :quantity
      t.integer :price
      t.integer :sum_price
      t.datetime :deleted_at

      t.timestamps
    end

    add_reference :product_balances, :sale_direct, foreign_key: {to_table: :product_sale_directs}, after: 'sale_item_id'
  end
end
