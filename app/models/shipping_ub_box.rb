class ShippingUbBox < ApplicationRecord
  belongs_to :shipping_ub

  has_many :shipping_ub_products, dependent: :destroy
  accepts_nested_attributes_for :shipping_ub_products, allow_destroy: true

  validates :shipping_ub_products, :length => {:minimum => 1}

  with_options :if => Proc.new {|m| m.is_box.present? && m.is_box} do
    validates :cost, presence: true
  end

  after_save :set_product_cost

  private

  def set_product_cost
    if is_box
      per_cost = self.cost / self.shipping_ub_products.count
      self.shipping_ub_products.each do |ub_p|
        ub_p.update_columns(cost: per_cost, per_price: per_cost / ub_p.quantity)
      end
    else
      self.shipping_ub_products.each do |ub_p|
        ub_p.update_columns(per_price: ub_p.cost / ub_p.quantity)
      end
    end

  end
end