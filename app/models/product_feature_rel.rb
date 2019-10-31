class ProductFeatureRel < ApplicationRecord
  belongs_to :product
  has_many :product_feature_option_rels, :class_name => "ProductFeatureOptionRel", :foreign_key => "feature_rel_id"
  has_many :product_income_items, :class_name => "ProductIncomeItem", :foreign_key => "feature_rel_id"
  has_many :product_balances, :class_name => "ProductBalance", :foreign_key => "feature_rel_id"
  has_many :product_sale_items

  has_attached_file :image, :path => ":rails_root/public/products/:id_partition/:style.:extension", styles: {original: "800x600>", tumb: "200x150>"}, :url => '/products/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 2.megabytes}

  validates :barcode, :sale_price, :image, :product_feature_option_rels, presence: true

  accepts_nested_attributes_for :product_feature_option_rels, allow_destroy: true

  before_save :set_defaults

  attr_accessor :pre_image

  scope :search, ->(p_id) {
    if p_id.nil?
      []
    else
      items = where(product_id: p_id)
      items.order(:created_at)
    end
  }

  def sale_price
    ApplicationController.helpers.get_f(self[:sale_price])
  end

  def discount_price
    ApplicationController.helpers.get_f(self[:discount_price])
  end

  def rel_names(mini_text = nil)
    option_names = ""

    self.product_feature_option_rels.each_with_index do |rel, index|
      option_names += (index == 0 ? "" : ", ")
      option_names += if mini_text.present?
                        rel.feature_option.name
                      else
                        "#{rel.feature_option.product_feature.name}: #{rel.feature_option.name}"
                      end
    end

    option_names
  end

  private

  def set_defaults
    self.discount_price = self.sale_price if discount_price.nil? || discount_price == 0
  end
end
