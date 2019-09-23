class ProductFeatureOptionRel < ApplicationRecord
  belongs_to :product, :class_name => "Product"
  belongs_to :feature_option, :class_name => "ProductFeatureOption"

  scope :search, ->(p_id, f_id) {
    items = where(product_id: p_id)
    items = items.where('feature_id = :value', value: f_id) if f_id.present?
    items.order(:feature_id)
  }

end
