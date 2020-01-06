class AddUserToSalesmanTravelSigns < ActiveRecord::Migration[5.2]
  def change
    add_reference :salesman_travel_signs, :user, foreign_key: true, after: 'salesman_travel_id'
    add_column :salesman_travels, :sign_at, :datetime, after: 'delivery_at'
  end
end
