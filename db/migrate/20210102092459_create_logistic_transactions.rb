class CreateLogisticTransactions < ActiveRecord::Migration[5.2]
  def change
    # create_table :logistic_transactions do |t|
    #   t.references :bank_transaction, foreign_key: true
    #   t.references :user, foreign_key: true
    #   t.references :logistic, foreign_key: true
    #   t.references :supply_order, foreign_key: {to_table: :product_supply_orders}
    #   t.float :exc_rate
    #   t.float :summary
    #   t.timestamps
    # end
    #
    # add_column :logistics, :balance, :integer, after: 'gender'
    # add_column :bank_transactions, :exchange, :integer, after: 'dealing_account_id'
    # add_column :bank_transactions, :exc_rate, :float, after: 'exchange'
    # add_column :shipping_ers, :per_price, :float, after: 'cost'
    # add_column :shipping_ub_products, :per_price, :float, after: 'cost'
    # add_column :product_income_products, :unit_price, :float, after: 'cargo'
    # add_column :product_income_products, :exc_rate, :float, after: 'unit_price'
    # add_column :product_income_products, :cost, :float, after: 'exc_rate'
    # add_column :product_sale_items, :bought_price, :float, after: 'bought_quantity'
    # add_column :salesmen, :distribution, :float, after: 'pin_code'
    # add_column :salesmen, :price, :integer, after: 'distribution'
    # add_column :salesmen, :price_at, :datetime, after: 'price'
    change_column :salesman_travel_routes, :wage, :integer
    # add_column :salesman_travel_routes, :distribution, :float, after: 'wage'
  end
end
