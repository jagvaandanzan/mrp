class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    # add_reference :product_sales, :parent, foreign_key: {to_table: :product_sales}, after: 'sale_call_id'
    # add_reference :product_sale_items, :parent, foreign_key: {to_table: :product_sale_items}, after: 'back_quantity'
    #
    # add_column :product_sales, :back_money, :integer, after: 'parent_id'
    change_column :shipping_ub_samples, :number, :integer, default: 1
  end
end
