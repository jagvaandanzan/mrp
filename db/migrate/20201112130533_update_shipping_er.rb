class UpdateShippingEr < ActiveRecord::Migration[5.2]
  def change
    add_column :shipping_ers, :cost, :float, limit: 53, after: 'date'
    add_column :shipping_ers, :s_type, :integer, after: 'cost'
    add_reference :product_supply_features, :product, foreign_key: true, after: 'feature_item_id'

  end
end
