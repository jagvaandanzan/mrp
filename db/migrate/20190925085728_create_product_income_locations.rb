class CreateProductIncomeLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_locations do |t|
      t.references :income_item, foreign_key: {to_table: :product_income_items}
      t.references :location, foreign_key: {to_table: :product_locations}
      t.integer :quantity

      t.timestamps
    end
  end
end
