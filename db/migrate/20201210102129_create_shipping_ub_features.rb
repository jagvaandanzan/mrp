class CreateShippingUbFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_ub_features do |t|
      t.references :shipping_ub_product, null: false, foreign_key: true
      t.references :shipping_er_feature, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :supply_feature, null: false, foreign_key: {to_table: :product_supply_features}
      t.integer :quantity

      t.timestamps
    end

    remove_reference :product_income_items, :shipping_ub_item
    add_reference :product_income_items, :shipping_ub_feature, foreign_key: true, after: 'product_income_id'
  end
end
