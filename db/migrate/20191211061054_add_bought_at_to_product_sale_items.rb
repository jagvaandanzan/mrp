class AddBoughtAtToProductSaleItems < ActiveRecord::Migration[5.2]
  def change
    add_column :product_sale_items, :bought_at, :datetime, after: 'to_see'
    add_column :product_sales, :paid, :integer, after: 'money'
  end
end
