class AddSyncAtToProductFeatures < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :sync_at, :datetime, before: 'created_at'
    add_column :product_features, :sync_at, :datetime, before: 'created_at'
    add_column :product_feature_options, :sync_at, :datetime, before: 'created_at'
    add_column :product_categories, :sync_at, :datetime, before: 'created_at'
  end
end
