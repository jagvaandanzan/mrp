class AddSourceToProductSales < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sales, :source, :integer, after: 'status_note'
    add_column :product_sale_calls, :source, :integer, after: 'message'
    add_column :product_sales, :feedback_period, :integer, after: 'cart_id'
  end
end
