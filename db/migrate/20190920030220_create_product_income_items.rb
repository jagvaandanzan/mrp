class CreateProductIncomeItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_items do |t|
      t.references :income, foreign_key: {to_table: :product_incomes}
      t.references :supply_order_item, foreign_key: {to_table: :product_supply_order_items}
      t.references :feature_rel, foreign_key: {to_table: :product_feature_rels}
      t.integer :quantity
      t.float :price, limit: 53
      t.float :shuudan
      t.integer :urgent_type
      t.string :note, limit: 1000
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
