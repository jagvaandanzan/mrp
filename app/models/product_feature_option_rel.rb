class ProductFeatureOptionRel < ApplicationRecord

  belongs_to :product
  belongs_to :feature_option, :class_name => "ProductFeatureOption"

  has_one :product_feature, through: :feature_option

  scope :by_feature_option_ids, ->(ids) {
    where("feature_option_id IN (?)", ids)
  }

  scope :by_feature_option_ids, ->(ids) {
    where("feature_option_id IN (?)", ids)
  }

  def by_size_feature_option11
    feature_option.each {||}
  end

  scope :by_size_feature_option, ->() {
    joins(:product_feature)
        .joins(:feature_option)
        .where("product_features.feature_type =? ", 1)
        .order('product_feature_options.queue')
        .select("product_feature_options.id, product_feature_options.name")

  }


end
