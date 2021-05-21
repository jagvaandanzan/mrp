class CreateProductSaleReturns < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_returns do |t|
      t.references :product_sale, foreign_key: true
      t.references :product_sale_item, foreign_key: true
      t.integer :quantity
      t.integer :take_quantity
      t.datetime :take_at

      t.timestamps
    end
    remove_reference :product_sale_items, :parent
    add_column :product_sales, :is_return, :boolean, after: 'parent_id', default: false
  end
end