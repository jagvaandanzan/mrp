class ProductSaleCall < ApplicationRecord
  acts_as_paranoid

  belongs_to :operator, optional: true
  belongs_to :status, :class_name => "ProductSaleStatus", optional: true
  has_many :product_call_items
  has_many :products, through: :product_call_items
  has_one :product_sale, :class_name => "ProductSale", :foreign_key => "sale_call_id"
  has_many :product_sale_status_logs

  accepts_nested_attributes_for :product_call_items, allow_destroy: true
  before_save :create_log

  attr_accessor :is_web, :status_m, :status_sub, :temp_operator

  validates :phone, presence: true
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}

  with_options :if => Proc.new {|m| m.is_web.present?} do
    validates :status_id, presence: true
    validates :product_call_items, length: {minimum: 1}
  end

  with_options :unless => Proc.new {|m| m.is_web.present?} do
    after_create :sent_itoms
    after_create :set_items
    validates_uniqueness_of :code, if: :has_24_created
    validates :code, presence: true, length: {is: 6}
  end

  scope :by_not_id, ->(id) {
    where.not(id: id) if id.present?
  }

  scope :by_not_status, ->(stat) {
    left_joins(:status)
        .where.not("product_sale_statuses.alias = ?", stat)
  }

  scope :by_operator_id, ->(id) {
    where(operator_id: id)
  }

  scope :by_phone, ->(phone) {
    where(phone: phone)
  }

  scope :by_status, ->(status) {
    joins(:status)
        .where('product_sale_statuses.alias = ?', status)
  }

  scope :search, ->(start, finish, phone, code_name, status) {
    items = order(created_at: :desc)
    items = items.where('phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.where(status_id: status) if status.present?
    # items = items.joins("LEFT OUTER JOIN `product_sales` ON `product_sales`.`deleted_at` IS NULL AND `product_sales`.`sale_call_id` = `product_sale_calls`.`id`").where("product_sales.id IS ?", nil) if status.present?
    items = items.joins(:products).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{code_name}%") if code_name.present?
    items = items.where('? <= created_at AND created_at <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  def status_name
    if status.previous.present?
      "#{status.previous_status.name} -- #{status.name}"
    else
      status.name
    end
  end

  def set_statuses
    if status.previous.present?
      self.status_m = status.previous_status.id
      self.status_sub = status_id
    else
      self.status_m = status_id
    end
  end

  private

  def has_24_created
    ProductSaleCall.where(phone: phone)
        .where(code: code)
        .where("created_at >= ?", Time.current - 1.days)
        .exists?
  end

  def set_items
    product = Product.find_by_code(code)
    if product.present?
      product_call_item = ProductCallItem.new(product_sale_call: self, product: product)
      product_call_item.save(validate: false)
    end
  end

  def create_log
    self.product_sale_status_logs << ProductSaleStatusLog.new(operator: temp_operator.presence || operator,
                                                              status: status,
                                                              note: message)
  end

  def sent_itoms
    param = {
        phone: phone,
        itemcode: code,
        description: message.gsub(phone.to_s, ''),
        operator: operator.present? && operator.order_sys_name.present? ? operator.order_sys_name : 'social'
    }
    response = ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/newenquiresocial", 'post', param.to_json)
    Rails.logger.debug("43.231.114.241:8882/api/newenquiresocial => #{param.to_s} => #{response.body.to_s}")
  end
end
