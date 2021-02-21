class ProductSupplyFeature < ApplicationRecord
  belongs_to :order_item, :class_name => "ProductSupplyOrderItem"
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :product
  has_one :product_income_balance, :class_name => "ProductIncomeBalance", :foreign_key => "supply_feature_id", dependent: :destroy
  has_many :shipping_er_features, class_name: "ShippingErFeature", foreign_key: "supply_feature_id", dependent: :destroy

  before_save :set_cn_name
  attr_accessor :is_create, :is_update, :remainder, :cn_name

  with_options :if => Proc.new {|m| m.is_create.present?} do
    validates :quantity, :price, presence: true
    validates_numericality_of :quantity, greater_than: 0
    before_save :set_product_balance
    before_save :set_sum_price
  end

  with_options :if => Proc.new {|m| m.is_update.present?} do
    validates :quantity_lo, :price_lo, presence: true
  end

  with_options :unless => Proc.new {|m| m.is_create.present?} do
    before_update :set_sum_price_lo
  end

  scope :find_to_er, ->(product_id = nil) {
    items = left_joins(:shipping_er_features)
                .left_joins(:order_item)
                .group("product_supply_features.id")
                .having("product_supply_features.quantity_lo IS NOT NULL")
                .having("SUM(shipping_er_features.quantity) IS NULL OR SUM(shipping_er_features.quantity) < product_supply_features.quantity_lo") # хэд хэд тасалж авсан тохиолдлыг шалгаж байна
                .select("product_supply_features.*, product_supply_features.quantity_lo - IFNULL(SUM(shipping_er_features.quantity), 0) as remainder")
    items = items.where(product_id: product_id) unless product_id.nil?
    items = items.where("product_supply_order_items.status < ?", 8)
    items
  }

  scope :by_feature_item_id, ->(feature_item_id) {
    where(feature_item_id: feature_item_id)
  }

  scope :by_product_id, ->(product_id) {
    where(product_id: product_id)
  }

  scope :by_feature_item_ids, ->(feature_item_ids) {
    where("feature_item_id IN (?)", feature_item_ids)
  }

  def price
    ApplicationController.helpers.get_f(self[:price])
  end

  def price_lo
    ApplicationController.helpers.get_f(self[:price_lo])
  end

  def code
    get_model.code
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[get_model.exchange_before_type_cast.to_i], 2)
  end

  private

  def get_model
    order_item.product_supply_order
  end

  def get_user
    order_item.product_supply_order.user
  end

  def set_sum_price
    self.sum_price = (price * quantity).to_f.round(1)
  end

  def set_sum_price_lo
    self.sum_price_lo = (price_lo * quantity_lo).to_f.round(1) if price_lo.present? && quantity_lo.present?
  end

  def set_product_balance
    if product_income_balance.present?
      self.product_income_balance.update(
          quantity: quantity
      )
    else
      self.product_income_balance = ProductIncomeBalance.create(product: order_item.product,
                                                                feature_item: feature_item,
                                                                user_supply: get_user,
                                                                quantity: quantity)
    end
  end

  def set_cn_name
    feature_item.update_column(:c_name, cn_name) if cn_name.present? && feature_item.name != cn_name
  end
end
