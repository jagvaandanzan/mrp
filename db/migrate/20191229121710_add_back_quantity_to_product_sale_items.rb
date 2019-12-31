class AddBackQuantityToProductSaleItems < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_items, :back_quantity, :integer, after: 'bought_quantity'
    add_column :product_sale_directs, :phone, :integer, after: 'salesman_id'
    add_reference :product_sale_directs, :sale_item, foreign_key: {to_table: :product_sale_items}, after:'feature_item_id'
    remove_column :product_balances, :deleted_at, :datetime
  end
end
