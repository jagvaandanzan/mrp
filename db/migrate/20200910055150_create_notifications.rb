class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :salesman, foreign_key: true
      t.references :salesman_travel, foreign_key: true
      t.references :product_sale_item, foreign_key: true
      t.string :title
      t.string :body_s
      t.string :body_u
      t.integer :n_type, default: 0

      t.timestamps
    end
  end
end
