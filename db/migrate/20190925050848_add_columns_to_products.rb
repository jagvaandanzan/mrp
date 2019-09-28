class AddColumnsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :sale_price, :float, limit: 53
    add_column :products, :discount_price, :float, limit: 53
  end
end
