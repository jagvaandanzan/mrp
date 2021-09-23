class DirectSale < ApplicationRecord
  belongs_to :sale_type, :class_name => "DirectSaleType"
  belongs_to :owner, :class_name => "User"
  belongs_to :user, optional: true
  belongs_to :purchaser, optional: true
  has_one :sale_tax

  has_many :direct_sale_items, dependent: :destroy
  accepts_nested_attributes_for :direct_sale_items, allow_destroy: true

  enum price_type: {particle: 0, wholesale: 1}

  attr_accessor :code

  validates :date, :sale_type_id, :price_type, presence: true
  after_create :add_bonus

  with_options :if => Proc.new {|m| m.sale_type_id.to_i == 1} do
    validates :purchaser_id, presence: true
  end
  with_options :if => Proc.new {|m| m.sale_type_id.to_i == 2} do
    validates :phone, presence: true
    validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}
  end
  with_options :if => Proc.new {|m| m.sale_type_id.to_i == 3} do
    validates :user_id, presence: true
  end

  scope :order_date, ->() {
    order(:date)
  }
  scope :by_phone, ->(phone) {
    where(phone: phone)
  }
  scope :search, ->(start, finish, id, product_name, sale_type, phone, tax) {
    items = order_date
    items = items.where('? <= date AND date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.joins(direct_sale_items: :product)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%").group("store_transfers.id") if product_name.present?
    items = items.where('id = ?', id) if id.present?
    items = items.where('sale_type_id = ?', sale_type) if sale_type.present?
    items = items.where('phone = ?', phone) if phone.present?
    items = items.where('tax = ?', tax) if tax.present?
    items
  }
  scope :by_tax, -> {
    where(tax: true)
  }

  scope :send_tax, ->(send) {
    left_joins(:sale_tax)
        .where("sale_taxes.id IS#{send == "true" ? ' NOT' : ''} ?", nil) if send.present?
  }

  def product_count
    direct_sale_items.sum(:quantity)
  end

  def product_price
    direct_sale_items.sum(:pay_price)
  end

  def buyer
    if sale_type_id == 1
      purchaser.full_name
    elsif sale_type_id == 2
      phone
    else
      user.name
    end
  end

  private

  def add_bonus
    if sale_type_id == 2
      sales = ProductSale.by_status('sals_delivered')
                  .by_phone(phone)
                  .count
      sales += DirectSale.by_phone(phone)
                   .count
      sales += ProductSaleDirect.by_phone(phone)
                   .count
      if sales > 1
        direct_sale_items.each(&:add_bonus)
      end
    end
  end

end
