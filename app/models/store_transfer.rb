class StoreTransfer < ApplicationRecord
  belongs_to :user
  belongs_to :store_from, :class_name => "Storeroom"
  belongs_to :store_to, :class_name => "Storeroom"

  has_many :store_transfer_items, dependent: :destroy
  accepts_nested_attributes_for :store_transfer_items, allow_destroy: true

  attr_accessor :code

  validates :date, :store_from_id, :store_to_id, presence: true
  validate :check_store_room

  scope :order_date, ->() {
    order(:date)
  }

  scope :search, ->(start, finish, product_name, store_to, store_from, user_id, value) {
    items = order_date
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.joins(store_transfer_items: :product)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%").group("store_transfers.id") if product_name.present?
    items = items.where('store_to_id = ?', store_to) if store_to.present?
    items = items.where('store_from_id = ?', store_from) if store_from.present?
    items = items.where('user_id = ?', user_id) if user_id.present?
    items = items.where('value LIKE :value', value: "%#{value}%") if value.present?
    items
  }

  def product_count
    store_transfer_items.sum(:quantity)
  end

  def product_price
    store_transfer_items.sum(:sum_price)
  end

  private

  def check_store_room
    self.errors.add(:store_to_id, " шилжүүлэх данстай адилхан байж болохгүй!") if store_from_id == store_to_id
  end

end
