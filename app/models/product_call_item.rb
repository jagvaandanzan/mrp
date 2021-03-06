class ProductCallItem < ApplicationRecord
  belongs_to :product_sale_call
  belongs_to :product
  belongs_to :feature_item, -> {with_deleted}, class_name: "ProductFeatureItem", optional: true

  attr_accessor :remainder

  before_validation :set_remainder
  validates :feature_item_id, :quantity, presence: true
  # validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder), greater_than: 0

  def get_balance
    ProductBalance.balance_sum(product_id, feature_item_id)
  end

  private

  def set_remainder
    self.remainder = if feature_item.present? && feature_item.balance.present?
                       feature_item.balance + (quantity_was.presence || 0) if product_id.present? && feature_item_id.present?
                     else
                       0
                     end
  end

end
