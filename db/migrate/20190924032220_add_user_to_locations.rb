class AddUserToLocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :locations, :operator, foreign_key: true, after: 'id'
    add_reference :locations, :user, foreign_key: true
  end
end
