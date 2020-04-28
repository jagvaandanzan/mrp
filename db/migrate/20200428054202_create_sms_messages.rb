class CreateSmsMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_messages do |t|
      t.references :operator, null: false, foreign_key: true
      t.integer :recipient
      t.integer :amount
      t.string :message

      t.timestamps
    end
  end
end
