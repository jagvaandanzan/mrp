class AddLocKhorooToLocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :locations, :loc_khoroo, foreign_key: true, after: 'id'
  end
end
