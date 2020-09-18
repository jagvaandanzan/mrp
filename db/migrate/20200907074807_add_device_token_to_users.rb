class AddDeviceTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    # add_column :users, :device_token, :text, after: 'tokens'
    # add_column :salesmen, :device_token, :text, after: 'avatar_file_name'
    add_column :brands, :description, :text, after: 'name'
    add_attachment :customers, :logo, after: 'sync_at'
  end
end
