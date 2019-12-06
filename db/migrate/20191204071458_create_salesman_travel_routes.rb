class CreateSalesmanTravelRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_travel_routes do |t|
      t.references :salesman_travel, foreign_key: true
      t.integer :queue
      t.integer :distance
      t.integer :duration
      t.integer :wage
      t.references :location, foreign_key: true
      t.references :product_sale, foreign_key: true

      t.datetime :load_at
      t.datetime :delivery_at
      t.datetime :delivered_at
      t.integer :delivery_time
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
