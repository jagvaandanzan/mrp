class CreateShippingUbItems < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_ub_items do |t|
      t.references :shipping_ub, null: false, foreign_key: true
      t.references :product_supply_feature, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :shipping_er_item, null: false, foreign_key: true
      t.integer :loaded
      t.integer :cargo
      t.integer :s_type
      t.float :cost

      t.timestamps
    end
  end
end
