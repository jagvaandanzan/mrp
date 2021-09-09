class CreateLogisticPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :logistic_permissions do |t|
      t.integer :queue
      t.string :name
      t.string :description

      t.timestamps
    end

    create_table :logistic_permission_rels do |t|
      t.references :logistic, null: false, foreign_key: true
      t.references :logistic_permission, null: false, foreign_key: true
      t.integer :role

      t.timestamps
    end
  end
end
