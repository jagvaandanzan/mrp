class ProductLocationTransfer < ApplicationRecord
  belongs_to :user
  belongs_to :product_location

  has_many :product_location_trans_items, :class_name => "ProductLocationTransItem", :foreign_key => "location_transfer_id"
  has_many :product_location_trans_tos, :class_name => "ProductLocationTransTo", :foreign_key => "location_transfer_id"

  validates :product_location_trans_items, :length => {:minimum => 1}

  scope :by_user_id, ->(user_id) {
    where(user_id: user_id)
  }
  scope :by_date, ->(date) {
    where('product_location_transfers.created_at >= ?', date)
        .where('product_location_transfers.created_at < ?', date + 1.days)
  }

  scope :by_open, ->(is_open) {
    if is_open.present?
      left_joins(:product_location_trans_items)
          .left_joins(:product_location_trans_tos)
          .having("SUM(product_location_trans_items.quantity) #{is_open ? '=' : '!='} SUM(product_location_trans_tos.quantity)")
          .group("product_location_transfers.id")
    end
  }

  def location_name
    product_location.name
  end

  def quantity
    product_location_trans_items.sum(:quantity)
  end

  def transferred
    product_location_trans_tos.sum(:quantity)
  end
end
