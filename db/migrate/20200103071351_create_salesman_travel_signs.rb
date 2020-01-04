class CreateSalesmanTravelSigns < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_travel_signs do |t|
      t.references :salesman_travel, foreign_key: true
      t.attachment :given
      t.attachment :received

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
