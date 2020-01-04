class AddTokenAuthToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :provider, :string, :null => false, :default => "email", after: 'last_sign_in_ip'
    add_column :users, :uid, :string, :null => false, :default => "", after: 'provider'
    add_column :users, :tokens, :text, after: 'uid'
  end
end
