class AddPermissionsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :user_permission, foreign_key: true, after: 'gender'
    add_reference :users, :user_position, foreign_key: true, after: 'user_permission_id'
    add_reference :admin_users, :admin_permission, foreign_key: true, after: 'email'
  end
end
