class AddCustomerToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :customer, foreign_key: true, after:'id'
  end
end
