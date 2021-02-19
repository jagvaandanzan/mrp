class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :instruction, :text, after: 'photo_web'
    change_column :products, :delivery_type, :string
  end
end
