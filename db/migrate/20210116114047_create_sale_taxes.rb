class CreateSaleTaxes < ActiveRecord::Migration[5.2]
  def change
    # add_column :product_feature_items, :p_6_8_p, :integer, after: 'p_6_8'
    # add_column :product_feature_items, :p_9_p, :integer, after: 'p_9_'
    # add_reference :product_location_balances, :product_feature_item, after:'feature_item_id'
    add_column :products, :is_web, :boolean, after: 'draft', default: true
  end
end
