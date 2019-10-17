class ProductSale < ApplicationRecord
  acts_as_paranoid

  belongs_to :location
  belongs_to :main_status, :class_name => "ProductSaleStatus"
  belongs_to :status, :class_name => "ProductSaleStatus"
  belongs_to :created_operator, :class_name => "Operator", optional: true
  belongs_to :approved_operator, :class_name => "Operator", optional: true

  has_many :product_sale_items
  has_many :product_sale_status_logs

  accepts_nested_attributes_for :product_sale_items, allow_destroy: true

  before_save :set_defaults

  enum money: {account: 1, cash: 0}

  attr_accessor :hour_now, :hour_start, :hour_end, :status_user_type

  validates_numericality_of :hour_end, greater_than: Proc.new(&:hour_start)
  validates :phone, :location_id, :product_sale_items, :money, :main_status, presence: true
  before_validation :validate_status
  validates :code, uniqueness: true

  # Утасны дугаар 8 оронтой байхаар шалгадаг, буруу байвал хадгалдаггүй
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }
  scope :search, ->(code, start, finish, phone, status_id, loc_id) {

    items = joins(:product_sale_items)
                .joins("LEFT JOIN products ON product_sale_items.product_id = products.id")
    items.order("product_sale_status.queue")

    items = items.where('phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.where('products.code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('main_status_id = :s OR status_id=:s', s: status_id) if status_id.present?
    items = items.where(location_id: loc_id) if loc_id.present?
    items = items.where('DATE(delivery_start) >= :s AND DATE(delivery_start) <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?

    items
  }
  def bonus
    ApplicationController.helpers.get_f(self[:bonus])
  end

  def sum_price
    ApplicationController.helpers.get_f(self[:sum_price])
  end

  def delivery_time
    delivery_start.strftime('%Y/%m/%d') + '&nbsp;&nbsp;' + delivery_start.hour.to_s + "-" + delivery_end.hour.to_s
  end

  private

  def set_defaults
    self.code = ApplicationController.helpers.get_code(ProductSale.last) unless code.present?

    self.delivery_end = delivery_start.change({hour: hour_end})
    self.delivery_start = delivery_start.change({hour: hour_start})

    s = 0
    if product_sale_items.present?
      product_sale_items.each do |item|
        s += (item.price * item.quantity) if item.price.present? && item.quantity.present?
      end
    end

    s -= bonus if bonus.present?

    s += 2000 if s < 20000

    self.sum_price = s
  end

  def validate_status
    if main_status.present?
      if main_status.get_status_childs(status_user_type).count > 0
        unless status.present?
          self.errors.add(:status_id, :blank)
        end
      else
        self.status = main_status
      end
    end
  end
end
