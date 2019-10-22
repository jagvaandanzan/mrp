class CreateProductIncomeBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_balances do |t|
      t.references :product, foreign_key: true
      t.references :supply_order_item, foreign_key: {to_table: :product_supply_order_items}
      t.references :income_item, foreign_key: {to_table: :product_income_items}
      t.references :user_supply, foreign_key: {to_table: :users}
      t.references :user_income, foreign_key: {to_table: :users}

      t.integer :quantity

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
