class CreateBankDealingAccounts < ActiveRecord::Migration[5.2]
  def change
    # create_table :bank_dealing_accounts do |t|
    #   t.integer :code
    #   t.string :name
    #   t.string :account
    #
    #   t.timestamps
    # end
    # add_column :bank_accounts, :code, :integer, after: 'id'

    # add_reference :bank_transactions, :salesman, foreign_key: true, after: 'account'
    # add_column :bank_transactions, :billing_date, :datetime, after: 'salesman_id'
    # add_reference :bank_transactions, :bank_account, foreign_key: true, after: 'billing_date'
    # add_reference :bank_transactions, :dealing_account, foreign_key: {to_table: :bank_dealing_accounts}, after: 'bank_account_id'
    add_column :product_supply_orders, :calculated, :datetime, after: 'sum_price'
  end
end
