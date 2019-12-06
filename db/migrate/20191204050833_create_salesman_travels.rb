class CreateSalesmanTravels < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_travels do |t|
      t.references :salesman, foreign_key: true
      t.integer :distance
      t.integer :duration
      t.integer :wage
      t.references :user, foreign_key: true
      t.datetime :load_at
      t.datetime :delivery_at
      t.datetime :delivered_at
      t.integer :delivery_time

      t.timestamps
    end
  end
end
