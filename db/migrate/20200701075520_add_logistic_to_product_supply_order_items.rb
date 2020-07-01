class AddLogisticToProductSupplyOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_supply_order_items, :logistic, foreign_key: true, after: 'note'
    add_column :product_supply_order_items, :note_lo, :text, after: 'logistic_id'
    add_column :product_supply_order_items, :sum_price_lo, :float, limit: 53, after: 'logistic_id'
    add_column :product_supply_features, :quantity_lo, :integer, after: 'note'
    add_column :product_supply_features, :price_lo, :float, after: 'quantity_lo', limit: 53
    add_column :product_supply_features, :sum_price_lo, :float, limit: 53, after: 'price_lo'
    add_column :product_supply_features, :note_lo, :text, after: 'price_lo'
    add_column :product_supply_order_items, :status, :integer, after: 'id', default: 0
    add_column :logistics, :remember_created_at, :datetime, after: 'password_is_reset'
    add_column :product_supply_order_items, :purchase_date, :datetime, after: 'note_lo'

  end
end
