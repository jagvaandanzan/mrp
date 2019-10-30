class CreateProductSupplyOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :product_supply_order_items do |t|
      t.references :product_supply_order, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity
      t.float :price, limit: 53
      t.float :sum_price, limit: 53
      t.float :sum_tug, limit: 53
      t.string :link, limit: 500
      t.float :shuudan
      t.string :note, limit: 1000

      t.timestamps
    end
  end
end
