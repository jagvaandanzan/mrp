class ShippingErItem < ApplicationRecord
  belongs_to :shipping_er
  belongs_to :product_supply_feature
  belongs_to :same_item, :class_name => "ShippingErItem", optional: true

  belongs_to :product
  has_many :shipping_ub_items
  has_one :feature_item, through: :product_supply_feature

  attr_accessor :remainder
  enum s_type: {post_cargo: 0, post_er: 1, cargo_er: 2, cargo_post: 3}

  with_options :if => Proc.new {|m| m.received.present? && m.received.to_i > 0} do
    validates :received, :s_type, presence: true
    validates_numericality_of :received, less_than_or_equal_to: Proc.new(&:remainder)
  end

  before_validation :check_float
  after_save :check_received

  scope :sum_received, ->(feature_id) {
    where(product_supply_feature_id: feature_id)
        .sum('received')
  }

  scope :find_to_ub, -> {
    left_joins(:shipping_ub_items)
        .group("shipping_er_items.id")
        .having("SUM(shipping_ub_items.loaded) IS NULL OR SUM(shipping_ub_items.loaded) < shipping_er_items.received")
        .select("shipping_er_items.*, shipping_er_items.received - IFNULL(SUM(shipping_ub_items.loaded), 0) as remainder")
  }

  def name
    "#{product.code} #{feature_item.name}"
  end

  private

  def check_float
    self.cost = 0 if cost.nil?
  end

  def check_received
    if !received.present? || received.to_i == 0
      self.destroy!
    end
  end

end
