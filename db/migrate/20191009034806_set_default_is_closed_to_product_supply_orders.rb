class SetDefaultIsClosedToProductSupplyOrders < ActiveRecord::Migration[5.2]
  def change
    change_column :product_supply_orders, :is_closed, :integer, :default => 0
  end
end
