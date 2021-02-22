class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_balances, :salesman_return, foreign_key: true, after: 'sale_direct_id'
  end
end
