class FbPost < ApplicationRecord

  validates :post_id, :product_name, :product_code, presence: true, length: {maximum: 255}
  validates_uniqueness_of :post_id

  has_many :fb_comments

  scope :order_date, -> {
    order(created_at: :desc)
  }

  scope :order_updated, -> {
    order(updated: :desc)
  }

  scope :by_post_id, ->(post_id) {
    where(post_id: post_id)
  }

  scope :search, ->(name, code) {
    items = order_date
    items = items.where('product_name LIKE :value', value: "%#{name}%") if name.present?
    items = items.where('product_code LIKE :value', value: "%#{code}%") if code.present?
    items
  }

  def full_name
    "#{product_name}, #{product_code}"
  end
end
