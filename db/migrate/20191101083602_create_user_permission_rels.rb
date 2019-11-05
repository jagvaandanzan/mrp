class CreateUserPermissionRels < ActiveRecord::Migration[5.2]
  def change
    create_table :user_permission_rels do |t|
      t.references :user, foreign_key: true
      t.references :user_permission, foreign_key: true
      t.integer :role

      t.timestamps
    end

    add_column :user_permissions, :queue, :integer, after: 'id'
    remove_column :users, :user_permission_id, :references
  end
end
