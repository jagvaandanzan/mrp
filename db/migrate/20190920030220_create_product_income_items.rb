class CreateProductIncomeItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_items do |t|
      t.references :product_income, foreign_key: true
      t.references :supply_order_item, foreign_key: {to_table: :product_supply_order_items}
      t.references :product, foreign_key: true
      t.references :product_supplier, foreign_key: true
      t.references :feature_rel, foreign_key: {to_table: :product_feature_rels}
      t.integer :quantity
      t.float :price, limit: 53
      t.float :shuudan
      t.integer :urgent_type
      t.datetime :date
      t.string :note, limit: 1000

      t.timestamps
    end
  end
end
