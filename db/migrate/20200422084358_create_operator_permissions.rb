class CreateOperatorPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :operator_permissions do |t|
      t.integer :queue
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :operator_permission_rels do |t|
      t.references :operator, null: false, foreign_key: true
      t.references :operator_permission, null: false, foreign_key: true
      t.integer :role

      t.timestamps
    end
  end
end
