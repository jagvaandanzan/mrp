class CreateProductIncomeLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :product_income_locations do |t|
      t.references :income_item
      t.references :location
      t.float :quantity, limit: 53

      t.timestamps
    end
  end
end
