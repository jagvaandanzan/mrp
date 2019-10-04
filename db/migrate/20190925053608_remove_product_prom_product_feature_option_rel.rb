class RemoveProductPromProductFeatureOptionRel < ActiveRecord::Migration[5.2]
  def change
    remove_reference :product_feature_option_rels, :product, index: true
    add_reference :product_feature_option_rels, :product_feature_rel, index: true

  end
end
