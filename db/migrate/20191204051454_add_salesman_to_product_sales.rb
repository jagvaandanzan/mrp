class AddSalesmanToProductSales < ActiveRecord::Migration[5.2]
  def change
    add_column :travel_configs, :max_distance, :integer, after: 'max_travel'
    add_reference :product_sales, :salesman_travel, foreign_key: true, after: 'approved_date'
  end
end
