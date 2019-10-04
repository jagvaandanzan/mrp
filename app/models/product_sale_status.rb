class ProductSaleStatus < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductSaleStatus", :foreign_key => "parent_id"
  belongs_to :parent, -> { with_deleted }, :class_name => "ProductSaleStatus", optional: true
  has_many :status_pers, :class_name => "ProductSaleStatusPer", :foreign_key => "status_id"
  has_many :product_sales, :class_name => "ProductSale", :foreign_key => "status_id"
  has_many :product_sale_status_logs, :class_name => "ProductSaleStatusLog", :foreign_key => "status_id"

  validates :name, :alias, presence: true
  validates :alias, uniqueness: true


  scope :order_by_queue, -> {
    order(:queue)
  }

  scope :search, ->(pid, per_type) {
    items = order_by_queue

    if pid.present?
      items = items.where(parent_id: pid)
    else
      items = items.where(parent_id: nil)
    end

    items = items.joins(:status_pers).where('product_sale_status_pers.user_type = ?', ProductSaleStatusPer.user_types[per_type]) if per_type.present?

    items
  }

  def name_with_parent
    (self.parent.present? ? self.parent.name + " >> " : "") + self.name
  end
end
