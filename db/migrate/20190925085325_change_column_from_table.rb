class ChangeColumnFromTable < ActiveRecord::Migration[5.2]
  def change
    remove_reference :product_income_items, :location, index: true
    # remove_reference :product_income_feature_rels, :feature_option, index: true
    # add_reference :product_income_feature_rels, :product_feature_rel, index: true
  end
end
