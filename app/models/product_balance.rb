class ProductBalance < ApplicationRecord
  acts_as_paranoid

  belongs_to :product
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  belongs_to :product_income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :sale_item, :class_name => "ProductSaleItem", optional: true
  belongs_to :user, optional: true
  belongs_to :operator, optional: true


  scope :balance, -> (product_id, feature_rel_id = nil) {
    items = where(product_id: product_id)
    items = items.where(feature_rel_id: feature_rel_id) if feature_rel_id.present?
    items.sum(:quantity)
  }
end
