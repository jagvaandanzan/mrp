class ShippingUbBox < ApplicationRecord
  belongs_to :shipping_ub

  has_many :shipping_ub_products, dependent: :destroy
  accepts_nested_attributes_for :shipping_ub_products, allow_destroy: true

  validates :shipping_ub_products, :length => {:minimum => 1}
end
