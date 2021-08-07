class CreateLocationZones < ActiveRecord::Migration[5.2]
  def change
    create_table :location_zones do |t|
      t.integer :queue
      t.string :name

      t.decimal "lat_l_t", precision: 15, scale: 10
      t.decimal "lng_l_t", precision: 15, scale: 10
      t.decimal "lat_l_b", precision: 15, scale: 10
      t.decimal "lng_l_b", precision: 15, scale: 10
      t.decimal "lat_r_t", precision: 15, scale: 10
      t.decimal "lng_r_t", precision: 15, scale: 10
      t.decimal "lat_r_b", precision: 15, scale: 10
      t.decimal "lng_r_b", precision: 15, scale: 10

      t.timestamps
    end

    add_reference :salesman_travels, :operator, foreign_key: true, after: 'salesman_id'
    add_column :salesman_travels, :zone_ids, :string, after: 'operator_id'
    add_column :salesman_travels, :description, :text, after: 'delivery_time'
  end
end
