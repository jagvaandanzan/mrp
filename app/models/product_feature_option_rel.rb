class ProductFeatureOptionRel < ApplicationRecord
  belongs_to :product_feature_rel, :class_name => "ProductFeatureRel", optional: true
  belongs_to :feature_option, :class_name => "ProductFeatureOption"

  validates :feature_option_id, presence: true

end
