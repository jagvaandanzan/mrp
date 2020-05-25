class ProductSaleCall < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :operator, optional: true

  # before_validation :set_remainder
  # attr_accessor :remainder
  after_create :sent_itoms

  validates_uniqueness_of :code, if: :has_24_created

  validates :code, presence: true, length: {is: 6}
  validates :phone, :quantity, presence: true
  validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}
  validates :quantity, numericality: {greater_than: 0}
  # validates_numericality_of :quantity, less_than_or_equal_to: Proc.new(&:remainder)

  scope :search, ->(start, finish, phone, code_name) {
    items = order(created_at: :desc)
    items = items.where('phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{code_name}%") if code_name.present?
    items = items.where('? <= created_at AND created_at <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items
  }

  def get_balance
    ProductBalance.balance(product_id)
  end

  private

  def set_remainder
    self.remainder = ProductBalance.balance(product_id) if product_id.present?
  end

  def has_24_created
    ProductSaleCall.where(phone: phone)
        .where(code: code)
        .where("created_at >= ?", Time.current - 1.days)
        .exists?
  end

  def sent_itoms
    param = {
        phone: phone,
        itemcode: code,
        description: message.gsub(phone.to_s, ''),
        operator: operator.present? && operator.order_sys_name.present? ? operator.order_sys_name : ''
    }
    response = ApplicationController.helpers.sent_itoms("http://43.231.114.241:8882/api/newenquiresocial", 'post', param.to_json)
    Rails.logger.debug("43.231.114.241:8882/api/newenquiresocial => #{response.code.to_s} => #{response.body.to_s}")
  end
end
