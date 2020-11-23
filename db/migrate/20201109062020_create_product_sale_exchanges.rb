class CreateProductSaleExchanges < ActiveRecord::Migration[5.2]
  def change
    add_column :product_warehouse_locs, :salesman_at, :datetime, after: 'load_at'
    add_column :product_sale_items, :add_stock, :boolean, after: 'to_see', default: 0
    add_column :product_warehouse_locs, :add_stock, :boolean, after: 'salesman_at', default: 0
  end
end
