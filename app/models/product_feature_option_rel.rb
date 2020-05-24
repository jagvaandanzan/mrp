class ProductFeatureOptionRel < ApplicationRecord

  belongs_to :product
  belongs_to :feature_option, :class_name => "ProductFeatureOption"

  scope :by_feature_option_ids, ->(ids) {
    where("feature_option_id IN (?)", ids)
  }

  scope :by_feature_option_ids, ->(ids) {
    where("feature_option_id IN (?)", ids)
  }

end
