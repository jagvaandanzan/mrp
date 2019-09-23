class CreateProductSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :product_suppliers do |t|
      t.string :code
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
