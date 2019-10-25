class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.integer :queue, default: 1
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
