class AddAliToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :ali_c, :integer, default: 0, after: 'name'
    add_column :users, :ali_g, :integer, default: 0, after: 'name'
    add_column :users, :ali_f, :integer, default: 0, after: 'name'
  end
end
