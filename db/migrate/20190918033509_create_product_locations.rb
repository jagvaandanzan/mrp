class CreateProductLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :product_locations do |t|
      t.string :name
      t.string :code
      t.references :parent, foreign_key: {to_table: :product_locations}
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
