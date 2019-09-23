class CreateProductIncomeItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_items do |t|
      t.references :income
      t.references :supply_order_item
      t.float :quantity
      t.float :price, limit: 53
      t.float :shuudan
      t.integer :urgent_type
      t.string :note, limit: 1000
      t.references :location

      t.timestamps
    end
  end
end
