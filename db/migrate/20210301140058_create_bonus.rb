class CreateBonus < ActiveRecord::Migration[5.2]
  def change
    add_column :product_feature_items, :cost, :integer, after: 'barcode'
  end
end
