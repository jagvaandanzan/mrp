class ShippingUbItem < ApplicationRecord
  belongs_to :shipping_ub
  belongs_to :product_supply_feature
  belongs_to :product
  belongs_to :shipping_er_item
  has_one :product_income_items
  has_one :feature_item, through: :product_supply_feature

  attr_accessor :remainder
  enum s_type: {simple: 0, urgent: 1}

  validates :loaded, :s_type, presence: true

  validates_numericality_of :loaded, less_than_or_equal_to: Proc.new(&:remainder)

  before_validation :check_float

  scope :sum_loaded, ->(feature_id) {
    where(product_supply_feature_id: feature_id)
        .sum('loaded')
  }

  private

  def check_float
    self.cost = 0 if cost.nil?
  end
end