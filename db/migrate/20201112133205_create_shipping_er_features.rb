class CreateShippingErFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_er_features do |t|
      t.references :shipping_er_product, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :supply_feature, null: false, foreign_key: {to_table: :product_supply_features}
      t.integer :quantity

      t.timestamps
    end
  end
end
