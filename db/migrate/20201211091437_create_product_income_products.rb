class CreateProductIncomeProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_products do |t|
      t.references :product_income, null: false, foreign_key: true
      t.references :shipping_ub_product, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.integer :cargo

      t.timestamps
    end
    add_reference :product_income_items, :income_product, foreign_key: {to_table: :product_income_products}, after: 'product_income_id'
    remove_column :product_incomes, :code, :string
    remove_column :product_income_items, :cargo, :integer

  end
end
