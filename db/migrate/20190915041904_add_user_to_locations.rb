class AddUserToLocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :locations, :user, foreign_key: true, after: 'id'
  end
end
