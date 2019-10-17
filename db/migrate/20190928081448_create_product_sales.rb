class CreateProductSales < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sales do |t|
      t.string :code
      t.datetime :delivery_start
      t.datetime :delivery_end
      t.integer :phone
      t.references :location, foreign_key: true
      t.string :building_code
      t.string :loc_note
      t.datetime :delivery_date
      t.float :payment_delivery, limit: 53
      t.integer :money
      t.float :bonus
      t.float :sum_price, limit: 53
      t.references :main_status, foreign_key: {to_table: :product_sale_statuses}
      t.references :status, foreign_key: {to_table: :product_sale_statuses}
      t.string :status_note

      t.references :created_operator, foreign_key: {to_table: :operators}
      t.references :approved_operator, foreign_key: {to_table: :operators}
      t.datetime :approved_date
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
