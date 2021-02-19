class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :supply_price, :boolean, default: false, after: 'name'
  end
end
