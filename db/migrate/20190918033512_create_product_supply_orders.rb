class CreateProductSupplyOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :product_supply_orders do |t|
      t.string :code
      t.datetime :ordered_date
      t.references :supplier, foreign_key: {to_table: :product_suppliers}
      t.integer :payment
      t.integer :exchange
      t.float :exchange_value
      t.datetime :closed_date
      t.integer :is_closed, default: 0
      t.integer :remainder

      t.timestamps
    end
  end
end
