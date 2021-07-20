class CreateSalesmanRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_requests do |t|
      t.references :salesman, foreign_key: true
      t.references :salesman_travel, foreign_key: true
      t.datetime :last_travel_at
      t.integer :last_route

      t.timestamps
    end
  end
end
