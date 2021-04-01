class AddActiveOperator < ActiveRecord::Migration[6.0]
  def change
    add_reference :product_sale_calls, :active_opr, foreign_key: {to_table: :operators}, after: 'operator_id'
  end
end
