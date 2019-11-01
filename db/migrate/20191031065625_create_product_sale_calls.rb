class CreateProductSaleCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sale_calls do |t|
      t.text :phone
      t.references :product, foreign_key: true
      t.integer :quantity
      t.references :operator, foreign_key: true

      t.timestamps
    end
  end
end
