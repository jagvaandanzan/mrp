class ProductIncomeFeatureRel < ApplicationRecord
  belongs_to :income_item, :class_name => "ProductIncomeItem", :foreign_key => "income_item_id", optional: true
  belongs_to :feature_option, :class_name => "ProductFeatureOption", :foreign_key => "feature_option_id"

  validates :feature_option_id, presence: true
end
