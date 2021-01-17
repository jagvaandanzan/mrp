class CreateSaleTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_taxes do |t|
      t.references :product_sale, null: false, foreign_key: true
      t.integer :tax_type
      t.integer :phone
      t.string :email
      t.integer :register
      t.integer :price

      t.timestamps
    end

    add_column :product_sales, :tax, :boolean, after: 'salesman_travel_id'
  end
end
