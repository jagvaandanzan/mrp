class AddCalculatedToProductIncomeItems < ActiveRecord::Migration[5.2]
  def change
    add_column :product_income_items, :calculated, :datetime, after: 'problematic'
    add_column :product_income_items, :clarify, :boolean, after: 'calculated', default: false
    add_column :product_income_items, :description, :text, after: 'clarify'
    add_column :product_income_products, :calculated, :datetime, after: 'cost'
    add_reference :product_income_products, :shipping_er, foreign_key: true, after: 'product_income_id'

    add_foreign_key :product_income_items, :product_income_products
    add_column :shipping_ub_samples, :per_cost, :float, :limit => 53, after: 'cost'
    change_column :shipping_ers, :per_price, :float, :limit => 53
    change_column :shipping_ub_products, :per_price, :float, :limit => 53
    change_column :bank_transactions, :exc_rate, :float
    remove_column :product_supply_orders, :sum_price
    remove_column :product_supply_orders, :calculated
    rename_column :product_income_products, :exc_rate, :cost_ub
    add_column :bank_transactions, :exc_summary, :float, after: 'exc_rate'
    change_column :logistics, :balance, :float

    drop_table :logistic_transactions
    create_table :logistic_balances do |t|
      t.references :logistic, foreign_key: true
      t.references :product_income_item, foreign_key: true
      t.float :price, :limit => 53
      t.datetime :date

      t.timestamps
    end
  end
end
