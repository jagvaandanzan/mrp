class ProductFeatureOptionRel < ApplicationRecord
  belongs_to :feature_rel, :class_name => "ProductFeatureRel", optional: true
  belongs_to :feature_option, :class_name => "ProductFeatureOption"

  has_many :product_features, through: :feature_option

  validates :feature_option_id, presence: true

end
