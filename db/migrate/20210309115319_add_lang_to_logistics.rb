class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    change_column :product_supply_order_items, :cost, :float
  end
end
