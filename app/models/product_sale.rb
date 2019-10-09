class ProductSale < ApplicationRecord
  belongs_to :location, :class_name => "Location", optional: true
  belongs_to :status, :class_name => "ProductSaleStatus", optional: true
  belongs_to :created_operator, :class_name => "Operator", optional: true
  belongs_to :approved_operator, :class_name => "Operator", optional: true

  has_many :product_sale_items, :class_name => "ProductSaleItem", :foreign_key => "product_sale_id"
  has_many :product_sale_status_logs, :class_name => "ProductSaleStatusLog", :foreign_key => "product_sale_id"

  validates :code, :phone, :status_id, presence: true

  validates :code, uniqueness: true

  # Утасны дугаар 8 оронтой байхаар шалгадаг, буруу байвал хадгалдаггүй
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true}

  validates_associated :product_sale_items

  # dor hayj neg baraa zarsa baih ystoi
  validate :sale_item_count

  accepts_nested_attributes_for :product_sale_items, allow_destroy: true

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }
  scope :search, ->(code, start, finish, phone, status_id, loc_id) {

    items = joins(:status)
    items.order("product_sale_status.queue")

    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.where('product_sale_statuses.id = :s OR product_sale_statuses.parent_id=:s', s: status_id) if status_id.present?
    items = items.where(location_id: loc_id) if loc_id.present?
    items = items.where('DATE(sale_date) >= :s AND DATE(sale_date) <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    # items = items.where('income_date >= :s AND income_date <= :f', s: "#{start}",   f: "#{finish}") if start.present? && finish.present?

    items
  }

  def sumPrice
    @s = 0

    if self.product_sale_items.present?
      self.product_sale_items.each do |item|
        # if item.price.present? && item.quantity.present?
        @s += (item.price * item.quantity) if item.price.present? && item.quantity.present?
        # end
      end
    end

    @s += self.payment_delivery if self.payment_delivery.present?

    @s
  end

  private
  def sale_item_count
    p "toog toolj uziiy " + self.product_sale_items.length.to_s
    errors.add(:product_sale_items, "baraa 0 ees ih baih ystoi") if self.product_sale_items.length <= 0
  end
end
