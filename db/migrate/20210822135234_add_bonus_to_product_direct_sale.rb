class AddBonusToProductDirectSale < ActiveRecord::Migration[5.2]
  def change
    add_column :salesmen, :reset_code, :string, after: 'encrypted_password'
    remove_index :salesmen, :email
    remove_column :salesmen, :allow_password_change

  end
end
