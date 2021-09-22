class RemoveLogStatAttr < ActiveRecord::Migration[5.2]
  def change
    # add_reference :product_sale_status_logs, :user, foreign_key: true, after: 'id'
    # add_reference :salesman_returns, :sale_return, foreign_key: {to_table: :product_sale_returns}, after: 'sale_item_id'
    # add_column :product_sale_returns, :back_quantity, :integer, after: 'take_at'
    # change_column_null :salesman_returns, :sale_item_id, true
    add_reference :product_sale_returns, :feature_item, foreign_key: {to_table: :product_feature_items}, after: 'product_sale_item_id'
    add_column :product_sale_returns, :deleted_at, :datetime, after: 'back_quantity'
  end
end
