class RemoveQuantityFromProductSupplyOrderItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_supply_order_items, :quantity, :integer
    remove_column :product_supply_order_items, :price, :float
    remove_column :product_supply_order_items, :shuudan, :float
    add_column :products, :name_en, :string, after: 'name'
    add_column :products, :name_cn, :string, after: 'name_en'
    add_column :product_supply_orders, :deleted_at, :datetime, after: 'user_id'
    add_reference :product_supply_order_items, :product_sample, foreign_key: true, after: 'product_supply_order_id'
    add_attachment :product_supply_order_items, :image, after: 'note'
    add_reference :product_income_balances, :supply_feature, foreign_key: {to_table: :product_supply_features}, after: 'supply_order_item_id'
    remove_column :product_income_balances, :supply_order_item_id, :references
    add_reference :product_income_balances, :feature_item, foreign_key: {to_table: :product_feature_items}, after: 'product_id'
  end
end
