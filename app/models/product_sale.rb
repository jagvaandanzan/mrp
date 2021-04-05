class ProductSale < ApplicationRecord
  acts_as_paranoid

  belongs_to :location
  belongs_to :status, :class_name => "ProductSaleStatus"
  belongs_to :created_operator, :class_name => "Operator", optional: true
  belongs_to :approved_operator, :class_name => "Operator", optional: true
  belongs_to :salesman_travel, optional: true
  belongs_to :sale_call, :class_name => "ProductSaleCall", optional: true
  belongs_to :parent, :class_name => "ProductSale", optional: true

  has_many :product_sale_items
  has_many :product_sale_status_logs
  has_one :bonus_balance, dependent: :destroy
  has_one :sale_tax
  has_one :salesman_travel_route, dependent: :destroy
  has_one :child, :class_name => "ProductSale", :foreign_key => "parent_id", dependent: :destroy

  accepts_nested_attributes_for :product_sale_items, allow_destroy: true

  enum money: {cash: 0, account: 1, mixed: 2}

  attr_accessor :hour_now, :hour_start, :hour_end, :update_status, :operator, :salesman, :status_m, :status_sub

  before_validation :check_exchange
  before_save :create_log
  before_save :set_defaults
  before_save :set_balance

  with_options :if => Proc.new {|m| m.update_status == nil} do
    validates_numericality_of :hour_end, greater_than: Proc.new(&:hour_start)
    validates :phone, :location_id, :product_sale_items, :money, presence: true
    validates :code, uniqueness: true
    validate :feature_rel_should_be_uniq
    validates :phone, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}
  end

  with_options :if => Proc.new {|m| m.country} do
    validate :check_money
  end

  validates :status_id, presence: true

  with_options :if => Proc.new {|m| m.money != 'cash'} do
    validates :paid, presence: true
  end
  with_options :if => Proc.new {|m| m.money != 'cash' && !m.parent_id.present?} do
    validates_numericality_of :paid, less_than_or_equal_to: Proc.new(&:sum_price)
  end

  with_options :if => Proc.new {|m| m.bonus.present?} do
    validate :check_bonus
  end

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :order_phone, -> {
    order(:phone)
  }

  scope :by_tax, -> {
    where(tax: true)
  }
  scope :by_phone, ->(phone) {
    where(phone: phone)
  }

  scope :send_tax, ->(send) {
    if send.present?
      items = left_joins(:sale_tax)
      if send == "true"
        items = items.where("sale_taxes.id IS NOT ?", nil)
      else
        items = items.where("sale_taxes.id IS ?", nil)
      end
      items
    end
  }

  scope :search, ->(code_name, start, finish, phone, status) {
    items = joins(:status)
    items = items.where('phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.joins(product_sale_items: :product)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{code_name}%").group("id") if code_name.present?
    items = items.where('product_sale_statuses.alias = ?', status) if status.present?
    items = items.where('? <= delivery_start AND delivery_start <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.order("product_sale_statuses.queue")
                .created_at_desc

    items
  }

  scope :by_salesman_nil, ->() {
    joins(:status)
        .where.not("approved_date IS ?", nil)
        .where('product_sale_statuses.alias = ?', 'oper_confirmed')
        .where("salesman_travel_id IS ?", nil)
        .order(:approved_date)
  }

  scope :by_delivery_end, ->(date) {
    where("delivery_end <= ?", date) if date.present?
  }

  scope :by_travel_ids, ->(ids) {
    where("salesman_travel_id IN (?)", ids)
  }
  scope :by_status, ->(status) {
    joins(:status)
        .where('product_sale_statuses.alias = ?', status)
  }

  scope :by_delivered, ->() {
    joins(:status)
        .where('product_sale_statuses.alias = ? OR product_sale_statuses.alias = ? OR product_sale_statuses.alias = ? ', 'sals_delivered', 'oper_replacement', 'oper_return')
  }
  scope :sum_paid_by_salesman, ->(salesman_id, start_time, end_time) {
    left_joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where('salesman_travels.delivered_at IS NOT ?', nil)
        .where('salesman_travels.delivered_at >= ?', start_time)
        .where('salesman_travels.delivered_at < ?', end_time + 1.days)
        .sum(:paid)

  }
  scope :report_sale_delivered, ->(salesman_id, start_time, end_time) {
    select("SUM(product_sales.paid) as paid, SUM(product_sales.bonus) as bonus, SUM(product_sales.back_money) as back_money")
        .joins(:status)
        .left_joins(:salesman_travel)
        .where("salesman_travels.salesman_id = ?", salesman_id)
        .where('salesman_travels.delivered_at IS NOT ?', nil)
        .where('salesman_travels.delivered_at >= ?', start_time)
        .where('salesman_travels.delivered_at < ?', end_time + 1.days)
        .where('product_sale_statuses.alias = ?', 'sals_delivered')
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

  def bought_price
    product_sale_items.sum(:bought_price)
  end

  def status_name
    if status.present?
      if parent_id.present?
        "#{status.name_with_parent} (#{parent.status.name})"
      else
        status.name_with_parent
      end
    else
      "Сонгоогүй"
    end
  end

  def distribution
    distributions = 0.0
    product_sale_items.not_nil_bought_quantity.each do |sale_item|
      distributions += if sale_item.price < Const::DISTRIBUTION[1]
                         1
                       elsif sale_item.bought_quantity > 2
                         3
                       else
                         sale_item.bought_quantity
                       end
      if distributions > 2
        distributions = 3
        break
      end
    end
    distributions
  end

  def bonus_add
    if product_sale_items.present?
      BonusBalance.balance_by_item(product_sale_items.map(&:id).to_a)
    else
      0
    end
  end

  def bonus_show
    bonu = Bonu.by_phone(phone)
    if bonu.present?
      b = bonu.first
      b.balance - bonus_add + (bonus_was.presence || 0)
    else
      0
    end
  end

  def add_bonus
    # 2 дахь худалдан авалтаас бонус бодно
    sales = ProductSale.by_status('sals_delivered')
                .by_phone(phone)
    if sales.present?
      product_sale_items.each(&:add_bonus)
    end
  end

  def set_statuses(is_edit)
    if status.previous.present? || (is_edit && status.alias == "sals_delivered")
      self.status_m = (is_edit && status.alias == "sals_delivered") ? status_id : status.previous_status.id
      self.status_sub = status_id
    else
      self.status_m = status_id
    end
  end

  def is_exchange
    if status.present?
      status_alias = parent.present? ? parent.status.alias : status.alias
      status_alias == "oper_replacement" || status_alias == "oper_return"
    else
      false
    end
  end

  def salesman_delivered
    if status.alias == "sals_delivered"
      salesman_travel.salesman.name
    else
      ""
    end
  end

  private

  def check_money
    self.errors.add(:money, " заавал дансаар төлсөн байх ёстой!") unless account?
  end

  def set_defaults
    if operator.present?
      self.code = ApplicationController.helpers.get_code(ProductSale.last) unless code.present?

      self.delivery_end = delivery_start.change({hour: hour_end}) if hour_end.present?
      self.delivery_start = delivery_start.change({hour: hour_start}) if hour_start.present?
      self.sum_price -= bonus if bonus.present?
    end
  end

  def check_bonus
    if bonus.present? && bonus > 0
      real_bonus = bonus - (bonus_was.nil? ? 0 : bonus_was)
      bonu = Bonu.by_phone(phone)
      if bonu.present?
        b = bonu.first
        if b.balance - bonus_add < real_bonus
          self.errors.add(:bonus, " хүрэхгүй байна!")
        elsif real_bonus > sum_price / 2
          self.errors.add(:bonus, " ашиглаж болох хэмжээ хэтэрсэн байна!")
        end
      else
        self.errors.add(:bonus, " хүрэхгүй байна!")
      end
    end
  end

  def feature_rel_should_be_uniq
    uniq_by_feature_rel = product_sale_items.uniq(&:feature_item_id)

    if product_sale_items.length != uniq_by_feature_rel.length
      self.errors.add(:product_sale_items, :taken_feature_rel)
    end
  end

  def create_log
    self.product_sale_status_logs << ProductSaleStatusLog.new(operator: operator,
                                                              salesman: salesman,
                                                              status: status,
                                                              note: status_note)
    # set_status
    if status.next.present?
      next_status = status.next_status
      if next_status.user_type == "auto"
        self.status = next_status
      elsif next_status.alias == "call_connect_again" || next_status.alias == "call_no_balance" || next_status.alias == "call_address_changed"
        sale_call.temp_operator = operator
        sale_call.temp_salesman = salesman
        sale_call.status = next_status
        sale_call.save(validate: false)
      end
    end

  end

  def set_balance
    if operator.present? && bonus.present? && bonus > 0
      bonu = Bonu.by_phone(phone)
      if bonu.present?
        b = bonu.first
        if bonus_balance.present?
          self.bonus_balance.update(bonu: b, bonus: -bonus)
        else
          self.bonus_balance = BonusBalance.new(bonu: b, bonus: -bonus)
        end
      end
    end

  end

  # тоо ширхэг нь - утгатай бол буцаалт, буцаалт солилт статустай + тоо ширхэгтэй бол устгана
  def check_exchange
    if is_exchange && !update_status.present?
      self.back_money = 0
      product_sale_items.each do |item|
        if item.parent_id.present?
          if item.quantity >= 0
            item.destroy
          elsif item.quantity < 0
            self.back_money = 0 if self.back_money.nil?
            self.back_money += item.sum_price
          end
        end

        self.back_money = nil if back_money == 0
      end
    end
  end
end
