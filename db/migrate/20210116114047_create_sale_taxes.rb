class CreateSaleTaxes < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :product_location_balances, :product_feature_items
    # add_reference :locations, :station, foreign_key: {to_table: :locations}, after: 'loc_khoroo_id'
  end
end
