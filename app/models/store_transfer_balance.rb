class StoreTransferBalance < ApplicationRecord
  belongs_to :product
  belongs_to :feature_item, -> {with_deleted}, :class_name => "ProductFeatureItem"
  belongs_to :user
  belongs_to :storeroom
  belongs_to :transfer_item, :class_name => "StoreTransferItem"

  scope :balance_sum, -> (product_id, feature_item_id, storeroom_id) {
    where(product_id: product_id)
        .where(feature_item_id: feature_item_id)
        .where(storeroom_id: storeroom_id)
        .sum(:quantity)
  }

  scope :by_storeroom, -> (product_id, feature_item_id, storeroom_id, transfer_item_id) {
    where(product_id: product_id)
        .where(feature_item_id: feature_item_id)
        .where(storeroom_id: storeroom_id)
        .where(transfer_item_id: transfer_item_id)
  }
  scope :by_storeroom_id, ->(storeroom_id) {
    where(storeroom_id: storeroom_id)
  }
end
