class AddProductSaleLog < ActiveRecord::Migration[5.2]
  def change
    # create_table :log_stats do |t|
    #   t.integer :queue
    #   t.string :name
    #   t.timestamps
    # end
    # add_reference :product_sale_logs, :salesman, foreign_key: true, after: 'operator_id'
    # add_reference :product_sale_logs, :salesman_travel, foreign_key: true, after: 'salesman_id'
    # add_reference :product_sale_logs, :user, foreign_key: true, after: 'salesman_travel_id'
    # add_reference :product_sale_logs, :log_stat, foreign_key: true, after: 'user_id'
    # add_reference :product_sale_logs, :product_sale, foreign_key: true, after: 'discount'
    # add_reference :product_sale_logs, :sale_item, foreign_key: {to_table: :product_sale_items}, after: 'product_sale_id'
    # add_reference :product_sales, :inh, foreign_key: {to_table: :product_sales}, after: 'parent_id'
    add_reference :product_sale_items, :log_stat, foreign_key: true, after: 'back_quantity'
    add_column :product_sale_items, :destroy_q, :integer, after: 'log_stat_id'
  end
end
