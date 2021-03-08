class CreateBonus < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_sale_status_logs, :product_sale_call, foreign_key: true, after: 'product_sale_id'
    add_reference :product_sale_status_logs, :salesman, foreign_key: true, after: 'operator_id'
    remove_reference :product_sale_calls, :status
    add_column :product_sale_statuses, :previous, :string, after: 'id'
    add_column :product_sale_statuses, :next, :string, after: 'alias'
    remove_reference :product_sale_statuses, :parent
    remove_column :product_sale_statuses, :deleted_at
    add_reference :product_sale_calls, :status, foreign_key: {to_table: :product_sale_statuses}, after: 'id'

    remove_reference :product_sale_calls, :status_sub
    remove_reference :product_sales, :main_status

    drop_table :product_call_statuses
  end
end
