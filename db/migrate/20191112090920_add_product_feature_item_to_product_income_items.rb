class AddProductFeatureItemToProductIncomeItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_income_items, :feature_item, foreign_key: {to_table: :product_feature_items}, after: 'feature_rel_id'
    add_reference :product_balances, :feature_item, foreign_key: {to_table: :product_feature_items}, after: 'feature_rel_id'
    add_reference :product_sale_items, :feature_item, foreign_key: {to_table: :product_feature_items}, after: 'product_feature_rel_id'

    remove_column :product_balances, :feature_rel_id, :references
  end
end
