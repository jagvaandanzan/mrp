class CreateShippingErProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_er_products do |t|
      t.references :shipping_er, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.integer :cargo

      t.timestamps
    end
  end
end
