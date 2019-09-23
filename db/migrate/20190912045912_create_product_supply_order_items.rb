class CreateProductSupplyOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_supply_order_items do |t|
      t.references :supply_order
      t.references :product
      t.float :quantity
      t.float :price, limit: 53
      t.string :link, limit: 500
      t.float :shuudan
      t.string :note, limit: 1000

      t.timestamps
    end
  end
end
