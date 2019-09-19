class AddDeletedAtToProductLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :product_locations, :deleted_at, :datetime
    add_index :product_locations, :deleted_at
  end
end
