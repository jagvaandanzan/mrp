class ProductSale < ApplicationRecord
  acts_as_paranoid

  belongs_to :location
  belongs_to :main_status, :class_name => "ProductSaleStatus"
  belongs_to :status, :class_name => "ProductSaleStatus"
  belongs_to :created_operator, :class_name => "Operator", optional: true
  belongs_to :approved_operator, :class_name => "Operator", optional: true
  belongs_to :salesman_travel, optional: true

  has_many :product_sale_items
  has_many :product_sale_status_logs
  has_one :salesman_travel_route, dependent: :destroy

  accepts_nested_attributes_for :product_sale_items, allow_destroy: true

  before_save :set_defaults

  enum money: {account: 1, cash: 0}

  attr_accessor :hour_now, :hour_start, :hour_end, :status_user_type, :update_status

  with_options :if => Proc.new {|m| m.update_status == nil} do
    validates_numericality_of :hour_end, greater_than: Proc.new(&:hour_start)
    validates :phone, :location_id, :product_sale_items, :money, presence: true
    validates :code, uniqueness: true
    validate :feature_rel_should_be_uniq
    validates :bonus, numericality: {greater_than_or_equal_to: 0, less_than: 100, message: :invalid}
    validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}
  end

  before_validation :validate_status
  validates :main_status, presence: true

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }
  scope :search, ->(code_name, start, finish, phone, status_id) {
    items = joins(:status)
    items = items.where('phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.joins(product_sale_items: :product)
                .where('products.code LIKE :value OR products.name LIKE :value', value: "%#{code_name}%").group("id") if code_name.present?
    items = items.where('main_status_id = :s OR status_id=:s', s: status_id) if status_id.present?
    items = items.where('? <= delivery_start AND delivery_start <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.order("product_sale_statuses.queue")
                .created_at_desc

    items
  }

  scope :by_salesman_nil, ->() {
    where.not("approved_date IS ?", nil)
        .where("main_status_id = ?", 2)
        .where("salesman_travel_id IS ?", nil)
        .order(:approved_date)
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

  def count_product
    product_sale_items.sum(:quantity)
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

    s -= ((bonus * s) / 100).to_i if bonus.present?

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

  def feature_rel_should_be_uniq
    uniq_by_feature_rel = product_sale_items.uniq(&:product_feature_rel_id)

    if product_sale_items.length != uniq_by_feature_rel.length
      self.errors.add(:product_sale_items, :taken_feature_rel)
    end
  end
end
