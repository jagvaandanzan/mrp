class CreateAdminPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_permissions do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
