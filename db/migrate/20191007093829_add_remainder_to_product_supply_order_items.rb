class AddRemainderToProductSupplyOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :product_supply_order_items, :remainder, :integer
  end
end
