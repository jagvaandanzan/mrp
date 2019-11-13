class RemoveProductFeatureRelsToProductFeatureRels < ActiveRecord::Migration[5.2]
  def change
    remove_column :product_sale_items, :product_feature_rel_id, :references
    add_reference :product_sale_items, :feature_rel, foreign_key: {to_table: :product_feature_rels}, after: 'product_id'
  end
end
