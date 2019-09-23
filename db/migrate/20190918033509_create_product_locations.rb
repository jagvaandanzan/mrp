class CreateProductLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :product_locations do |t|
      t.string :name
      t.string :code
      t.references :parent

      t.timestamps
    end
  end
end
