class ProductFeatureRel < ApplicationRecord
  belongs_to :product
  has_many :product_feature_option_rels, -> {joins(:product_features).order("product_features.queue")}, :class_name => "ProductFeatureOptionRel", :foreign_key => "feature_rel_id"
  has_many :feature_options, through: :product_feature_option_rels
  has_many :product_income_items, :class_name => "ProductIncomeItem", :foreign_key => "feature_rel_id"
  has_many :product_balances, :class_name => "ProductBalance", :foreign_key => "feature_rel_id"
  has_many :product_sale_items, :class_name => "ProductSaleItem", :foreign_key => "feature_rel_id"
  has_many :product_feature_items, :class_name => "ProductFeatureItem", :foreign_key => "feature_rel_id", dependent: :destroy

  has_attached_file :image, :path => ":rails_root/public/products/:id_partition/:style.:extension", styles: {original: "800x600>", tumb: "200x150>"}, :url => '/products/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 2.megabytes}

  validates :barcode, :product_feature_option_rels, presence: true
  validate :option_should_be_uniq

  accepts_nested_attributes_for :product_feature_option_rels, allow_destroy: true

  before_save :set_defaults
  before_save :set_option_item
  after_save :set_option_item_single

  def sale_price
    ApplicationController.helpers.get_f(self[:sale_price])
  end

  def discount_price
    ApplicationController.helpers.get_f(self[:discount_price])
  end

  private

  def option_should_be_uniq
    uniq_by_option = product_feature_option_rels.uniq(&:feature_option_id)
    if product_feature_option_rels.length != uniq_by_option.length
      self.errors.add(:product_feature_option_rels, :taken)
    end
  end

  def set_defaults
    self.sale_price = 0 if sale_price.nil?
    self.discount_price = self.sale_price if discount_price.nil? || discount_price == 0
  end

  def set_option_item

    options = Hash.new
    product_feature_option_rels.each do |option_rel|
      if option_rel._destroy
        ProductFeatureItem.where('option1_id = :feature_option_id OR option2_id = :feature_option_id', feature_option_id: option_rel.feature_option_id).destroy_all
      else
        if self.product_feature_items.exists?(['option1_id = :feature_option_id OR option2_id = :feature_option_id', feature_option_id: option_rel.feature_option_id])
          options[option_rel.feature_option_id] = 'upt'
        else
          options[option_rel.feature_option_id] = 'new'
        end
      end
    end

    product_feature_items.each {|item|
      unless options.has_key?(item.option1_id) || options.has_key?(item.option1_id)
        item.destroy
      end
    }

    array_inserted = []
    options.each {|key1, value|
      if value == "new"
        options.each_key {|key2|
          if key1 != key2 && !array_inserted.include?(key2.to_s + "-" + key1.to_s)
            option1 = ProductFeatureOption.find(key1)
            option2 = ProductFeatureOption.find(key2)
            if option1.product_feature_id != option2.product_feature_id
              product_feature_items << ProductFeatureItem.new(product: product, feature_rel: self, feature1_id: option1.product_feature_id, option1_id: key1, feature2_id: option2.product_feature_id, option2_id: key2)
            end
            array_inserted << (key1.to_s + "-" + key2.to_s)
          end
        }
      end
    }
  end

  def set_option_item_single
    if product_feature_items.count == 0 && product_feature_option_rels.count == 1
      product_feature_option = product_feature_option_rels.first
      ProductFeatureItem.create(product: product, feature_rel: self, option1_id: product_feature_option.feature_option_id, option2_id: product_feature_option.feature_option_id)
    end
  end
end
