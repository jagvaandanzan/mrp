class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_contacts do |t|
      t.references :customer, foreign_key: true
      t.integer :delivery
      t.integer :condition
      t.integer :price

      t.timestamps
    end

    create_table :customer_contact_fees do |t|
      t.references :customer,  foreign_key: true
      t.integer :range_s
      t.integer :range_e
      t.integer :percent

      t.timestamps
    end
    change_column :products, :is_own, :boolean
  end
end
