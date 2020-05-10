class CreateBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.string :name_en
      t.string :account
      t.timestamps
    end
  end
  add_reference :sms_messages, :bank_account, foreign_key: true, after: 'id'
end
