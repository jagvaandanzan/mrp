class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    # add_reference :product_sales, :parent, foreign_key: {to_table: :product_sales}, after: 'sale_call_id'
    add_reference :product_sale_items, :parent, foreign_key: {to_table: :product_sale_items}, after: 'back_quantity'

    add_column :product_sales, :back_money, :integer, after: 'parent_id'
    add_column :product_sale_items, :bought_price, :float, after: 'bought_quantity'
    drop_table :product_sale_exchanges
  end
end
