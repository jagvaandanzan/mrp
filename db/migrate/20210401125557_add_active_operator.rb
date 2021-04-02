class AddActiveOperator < ActiveRecord::Migration[5.2]
  def change
    # add_reference :product_sale_calls, :active_opr, foreign_key: {to_table: :operators}, after: 'operator_id'
    # remove_column :product_income_products, :calculated
    # remove_column :product_income_products, :cost_ub
    # add_column :product_incomes, :cargo_per, :float, after: 'cargo_price'
    add_reference :shipping_er_products, :supply_order, foreign_key: {to_table: :product_supply_orders}, after: 'id'
    add_reference :shipping_ub_products, :supply_order, foreign_key: {to_table: :product_supply_orders}, after: 'id'
  end
end
