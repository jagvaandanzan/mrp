class ProductCallItem < ApplicationRecord
  belongs_to :product_sale_call
  belongs_to :product
  belongs_to :feature_item, class_name: "ProductFeatureItem", optional: true

  attr_accessor :remainder

  before_validation :set_remainder
  validates :feature_item_id, :quantity, presence: true
  validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  def get_balance
    ProductBalance.balance_sum(product_id, feature_item_id)
  end

  private

  def set_remainder
    self.remainder = feature_item.balance + (quantity_was.presence || 0) if product_id.present? && feature_item_id.present?
  end

end
