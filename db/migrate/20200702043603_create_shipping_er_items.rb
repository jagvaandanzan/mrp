class CreateShippingErItems < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_er_items do |t|
      t.references :shipping_er, null: false, foreign_key: true
      t.references :product_supply_feature, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :received
      t.integer :cargo
      t.integer :s_type
      t.float :cost, limit: 53
      t.string :number

      t.timestamps
    end
  end
end
