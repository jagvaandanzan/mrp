class ProductSaleStatus < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductSaleStatus", :foreign_key => "parent_id"
  belongs_to :parent, -> {with_deleted}, :class_name => "ProductSaleStatus", optional: true
  has_many :product_sales, :class_name => "ProductSale", :foreign_key => "status_id"
  has_many :product_sale_status_logs, :class_name => "ProductSaleStatusLog", :foreign_key => "status_id"

  validates :name, :alias, presence: true
  validates :alias, uniqueness: true


  scope :order_by_queue, -> {
    order(:queue)
  }

  scope :search, ->(pid, user_type) {
    items = order_by_queue

    if pid.present?
      items = items.where(parent_id: pid)
    else
      items = items.where(parent_id: nil)
    end

    items = items.where('user_type = ?', user_type) if user_type.present?

    items
  }


  scope :get_statuses, ->(user_type) {
    grouped_options = []
    items = where("user_type LIKE :value", value: "%#{user_type}%")
                .where("parent_id IS NULL")

    items.each do |item|
      grouped_options.push(
          [item.name, item.get_status_childs(user_type)])
    end

    grouped_options
  }

  def get_status_childs(user_type)
    ProductSaleStatus.
        where("user_type LIKE :value", value: "%#{user_type}%")
        .where("parent_id = ?", self.id)
        .map {|i| i.name }
  end

  def name_with_parent
    (self.parent.present? ? self.parent.name + " >> " : "") + self.name
  end

end
