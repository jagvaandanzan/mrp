class ShippingUbItem < ApplicationRecord
  belongs_to :shipping_ub
  belongs_to :product_supply_feature
  belongs_to :product
  belongs_to :shipping_er_item
  belongs_to :same_item, :class_name => "ShippingUbItem", optional: true

  has_many :product_income_items
  has_one :feature_item, through: :product_supply_feature

  attr_accessor :remainder
  enum s_type: {simple: 0, urgent: 1}

  with_options :if => Proc.new {|m| m.loaded.present? && m.loaded.to_i > 0} do
    validates :loaded, :s_type, presence: true
    validates_numericality_of :loaded, less_than_or_equal_to: Proc.new(&:remainder)
  end

  before_validation :check_float
  after_validation :check_load

  scope :sum_loaded, ->(feature_id) {
    where(product_supply_feature_id: feature_id)
        .sum('loaded')
  }

  scope :find_to_incomes, -> {
    left_joins(:product_income_items)
        .group("shipping_ub_items.id")
        .having("SUM(product_income_items.quantity) IS NULL OR SUM(product_income_items.quantity) < shipping_ub_items.loaded")
        .select("shipping_ub_items.*, shipping_ub_items.loaded - IFNULL(SUM(product_income_items.quantity), 0) as remainder")
  }

  scope :by_order_item_id, ->(order_item_id) {
    joins(:product_supply_feature)
        .where('product_supply_features.order_item_id = ?', order_item_id)
  }

  def un_loaded
    loaded - product_income_items.sum(:quantity)
  end

  def name
    "#{product.code} #{feature_item.name}"
  end

  private

  def check_float
    self.cost = 0 if cost.nil?
  end

  def check_load
    if !loaded.present? || loaded.to_i == 0
      self.destroy!
    end
  end
end