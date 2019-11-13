class AddQueueToProductFeatures < ActiveRecord::Migration[5.2]
  def change
    add_column :product_features, :queue, :integer, after: 'id', default: 0
    add_column :product_feature_options, :queue, :integer, after: 'id', default: 0
  end
end
