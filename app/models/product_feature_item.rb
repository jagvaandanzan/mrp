class ProductFeatureItem < ApplicationRecord
  belongs_to :product
  belongs_to :feature_rel, :class_name => "ProductFeatureRel"
  belongs_to :feature1, :class_name => "ProductFeature"
  belongs_to :option1, :class_name => "ProductFeatureOption"
  belongs_to :feature2, :class_name => "ProductFeature"
  belongs_to :option2, :class_name => "ProductFeatureOption"


  scope :search, ->(product_id) {
    if product_id.nil?
      []
    else
      where(product_id: product_id)
      # SELECT `product_feature_items`.* FROM `product_feature_items` INNER JOIN `product_features` ON `product_features`.` id ` = ` product_feature_items `.` feature1_id ` AND ` product_features `.` deleted_at ` IS NULL INNER JOIN ` product_features ` ` feature2s_product_feature_items ` ON ` feature2s_product_feature_items `.` id ` = ` product_feature_items `.` feature2_id ` AND ` feature2s_product_feature_items `.` deleted_at ` IS NULL INNER JOIN ` product_feature_options ` ON ` product_feature_options `.` id ` = ` product_feature_items `.` option1_id ` AND ` product_feature_options `.` deleted_at ` IS NULL INNER JOIN ` product_feature_options ` ` option2s_product_feature_items ` ON ` option2s_product_feature_items `.` id ` = ` product_feature_items `.` option2_id ` AND ` option2s_product_feature_items `.` deleted_at ` IS NULL WHERE ` product_feature_items `.` product_id ` = 12 ORDER BY IF(product_features.queue<feature2s_product_feature_items.queue, product_features.queue, feature2s_product_feature_items.queue)
      # .order("IF(product_features.queue<feature2s_product_feature_items.queue, product_features.queue, feature2s_product_feature_items.queue)")
    end
  }

  def name
    if option1_id == option2_id
      option1.name.to_s
    else
      if feature1.queue < feature2.queue
        option1.name.to_s + " - " + option2.name.to_s
      elsif feature1.queue > feature2.queue
        option2.name.to_s + " - " + option1.name.to_s
      else
        if option2.queue < option1.queue
          option2.name.to_s + " - " + option1.name.to_s
        else
          option1.name.to_s + " - " + option2.name.to_s
        end
      end
    end
  end

  def price
    self.feature_rel.discount_price
  end
end
