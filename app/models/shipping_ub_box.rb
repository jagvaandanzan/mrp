class ShippingUbBox < ApplicationRecord
  belongs_to :shipping_ub

  has_many :shipping_ub_products, dependent: :destroy
  accepts_nested_attributes_for :shipping_ub_products, allow_destroy: true

  enum box_type: {is_open: 0, is_box: 1, is_sample: 2}

  validates :shipping_ub_products, :length => {:minimum => 1}

  with_options :if => Proc.new {|m| m.box_type.present? && m.is_box?} do
    validates :cost, presence: true
  end

  after_save :set_product_cost

  scope :by_date, ->(start, finish) {
    where('? <= created_at AND created_at <= ?', start.to_time, finish.to_time + 1.days)
  }

  scope :by_shipping_id, ->(ids){
    where(shipping_ub_id: ids)
  }

  private

  def set_product_cost
    if is_box?
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