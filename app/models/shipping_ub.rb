class ShippingUb < ApplicationRecord
  belongs_to :logistic

  has_many :shipping_ub_products, dependent: :destroy
  has_many :shipping_ub_boxes, dependent: :destroy
  has_many :shipping_ub_samples, dependent: :destroy
  has_many :products, through: :shipping_ub_products

  accepts_nested_attributes_for :shipping_ub_boxes, allow_destroy: true
  accepts_nested_attributes_for :shipping_ub_samples, allow_destroy: true

  enum s_type: {simple: 0, urgent: 1}

  before_validation :check_ub_products
  validates :date, :s_type, presence: true

  with_options :unless => Proc.new {|m| m.shipping_ub_samples.present?} do
    validates :shipping_ub_boxes, :length => {:minimum => 1}
  end
  with_options :unless => Proc.new {|m| m.shipping_ub_boxes.present?} do
    validates :shipping_ub_samples, :length => {:minimum => 1}
  end
  attr_accessor :number

  scope :order_created_at, -> {
    order(:date)
  }

  scope :search, ->(start, finish, product_name) {
    items = order_created_at
    items = items.joins(:products)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%").group("id") if product_name.present?
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  def shipping_ub_features
    shipping_ub_products
        .sum(:quantity)
  end

  def cargo_price
    shipping_ub_products.sum(:cost) + shipping_ub_samples.sum(:cost)
  end

  def cargo
    shipping_ub_products.sum(:cargo) + shipping_ub_samples.sum(:number)
  end

  def product_names
    names = ""
    products.each_with_index {|product, index|
      if index > 0
        names += ", "
      end
      names += product.full_name
    }
    names
  end

  private

  def check_ub_products
    if shipping_ub_samples.present?
      shipping_ub_boxes.each do |box|
        unless box.shipping_ub_products.present?
          box.destroy
        end
      end
    end
  end
end
