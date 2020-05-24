class ProductFilterGroup < ApplicationRecord
  belongs_to :product
  belongs_to :category_filter_group
  has_many :product_filters, dependent: :destroy

  validates :category_filter_group_id, presence: true
end
