class CreateLogisticTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :logistic_transactions do |t|
      t.references :bank_transaction, foreign_key: true
      t.references :user, foreign_key: true
      t.references :logistic, foreign_key: true
      t.references :supply_order, foreign_key: {to_table: :product_supply_orders}
      t.float :exc_rate
      t.float :summary
      t.timestamps
    end

    add_column :logistics, :balance, :integer, after: 'gender'
    add_column :bank_transactions, :exchange, :integer, after: 'dealing_account_id'
    add_column :bank_transactions, :exc_rate, :float, after: 'exchange'
  end
end
