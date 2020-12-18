class CreateBankDealingAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_dealing_accounts do |t|
      t.integer :code
      t.string :name
      t.string :account

      t.timestamps
    end

    add_column :bank_accounts, :code, :integer, after: 'id'
  end
end
