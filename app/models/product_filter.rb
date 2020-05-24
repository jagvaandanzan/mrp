class ProductFilter < ApplicationRecord
  belongs_to :product
  belongs_to :product_filter_group, optional: true
  belongs_to :category_filter

  validates :category_filter_id, presence: true

  scope :by_filter_ids, ->(filter_ids) {
    where("category_filter_id IN (?)", filter_ids)
  }

end
