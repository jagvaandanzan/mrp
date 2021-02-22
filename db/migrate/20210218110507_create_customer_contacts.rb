class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :products, :users
  end
end
