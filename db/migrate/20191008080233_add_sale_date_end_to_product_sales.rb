class AddSaleDateEndToProductSales < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sales, :sale_date_end, :datetime
  end
end
