class FbPost < ApplicationRecord
  acts_as_paranoid

  validates :post_id, :product_name, :product_code, :price, presence: true, length: {maximum: 255}
  validates_uniqueness_of :post_id
  validates :content, presence: true

  has_many :fb_comments, dependent: :destroy

  scope :order_date, -> {
    order(created_at: :desc)
  }
  scope :order_code, -> {
    order(:product_code)
  }

  scope :order_updated, -> {
    order(updated: :desc)
  }

  scope :by_post_id, ->(post_id) {
    where(post_id: post_id)
  }

  scope :search, ->(post_id, name, code) {
    items = order_date
    items = items.where(post_id: post_id) if post_id.present?
    items = items.where('product_name LIKE :value', value: "%#{name}%") if name.present?
    items = items.where('product_code LIKE :value', value: "%#{code}%") if code.present?
    items
  }

  def full_name
    "#{product_name}, #{product_code}"
  end
end
