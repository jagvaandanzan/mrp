class CreateProductSales < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sales do |t|
      t.string :code
      t.datetime :sale_date
      t.integer :phone
      t.references :location
      t.string :building_code
      t.string :loc_note
      t.datetime :delivery_date
      t.string :payment_delivery
      t.string :payment_account
      t.references :status
      t.string :status_note
      t.references :created_operator
      t.references :approved_operator
      t.datetime :approved_date

      t.timestamps
    end
  end
end
