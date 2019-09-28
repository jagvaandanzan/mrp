class ProductFeatureRel < ApplicationRecord
  belongs_to :product, :class_name => "Product"
  has_many :product_feature_option_rels, :class_name => "ProductFeatureOptionRel", :foreign_key => "product_feature_rel_id"
  has_many :product_income_items, :class_name => "ProductIncomeItem", :foreign_key => "product_feature_rel_id"


  validates :product_id, :barcode, :sale_price, :discount_price, presence: true

  accepts_nested_attributes_for :product_feature_option_rels, allow_destroy: true

  scope :search, ->(p_id) {
    items = where(product_id: p_id)
    items.order(:created_at)
  }

  scope :search_with_nil, ->(p_id) {
    unless p_id.nil?
      items = where(product_id: p_id)
      items.order(:created_at)
    else
      nil
    end
  }

  def rel_names
    option_names = ""

    self.product_feature_option_rels.each_with_index do |rel, index|
      option_names += (index == 0 ? "" : ", ")
      option_names += "#{rel.feature_option.product_feature.name}: #{rel.feature_option.name}"
    end

    option_names
  end
end
