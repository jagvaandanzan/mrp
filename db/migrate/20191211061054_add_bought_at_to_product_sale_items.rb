class AddBoughtAtToProductSaleItems < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_items, :bought_at, :datetime, after: 'to_see'
    add_column :product_sale_items, :bought_quantity, :integer, after: 'bought_at'
    add_column :product_sales, :paid, :integer, after: 'money'
    add_column :salesman_travel_routes, :payable, :integer, after: 'delivery_time'
  end
end
