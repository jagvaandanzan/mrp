class AddColumnToProductIncomeItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_income_items, :product_feature_rel, index: true
  end
end
