class CreateProductSupplyOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :product_supply_orders do |t|
      t.string :code
      t.datetime :ordered_date
      t.references :supplier
      t.integer :payment
      t.integer :exchange
      t.float :exchange_value
      t.datetime :closed_date
      t.boolean :is_closed

      t.timestamps
    end
  end
end
