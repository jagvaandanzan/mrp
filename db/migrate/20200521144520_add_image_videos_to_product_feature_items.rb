class AddImageVideosToProductFeatureItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :product_feature_items, :same_item, foreign_key: {to_table: :product_feature_items}, after: 'c_balance'
    add_attachment :product_feature_items, :video, after: 'same_item_id'
    add_attachment :product_feature_items, :image, after: 'same_item_id'
  end
end
