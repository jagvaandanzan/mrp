class CreateBankTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_transactions do |t|
      t.datetime :date
      t.string :value
      t.float :first_balance
      t.integer :summary
      t.float :final_balance
      t.string :account

      t.timestamps
    end
  end
end
