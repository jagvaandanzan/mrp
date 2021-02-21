class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :product_supply_order_items, :cost, :integer, after: 'note_lo'
  end
end
