class ProductSale < ApplicationRecord
  acts_as_paranoid

  belongs_to :location
  belongs_to :status, :class_name => "ProductSaleStatus"
  belongs_to :created_operator, :class_name => "Operator", optional: true
  belongs_to :approved_operator, :class_name => "Operator", optional: true
  belongs_to :salesman_travel, optional: true
  belongs_to :sale_call, :class_name => "ProductSaleCall", optional: true
  belongs_to :parent, :class_name => "ProductSale", optional: true
  belongs_to :inh, :class_name => "ProductSale", optional: true

  has_many :product_sale_items, dependent: :destroy
  has_many :product_sale_returns
  has_many :product_sale_status_logs
  has_one :bonus_balance, dependent: :destroy
  has_one :sale_tax
  has_one :salesman_travel_route, dependent: :destroy
  has_one :child, :class_name => "ProductSale", :foreign_key => "parent_id", dependent: :destroy
  has_many :products, through: :product_sale_items

  accepts_nested_attributes_for :product_sale_items, allow_destroy: true
  accepts_nested_attributes_for :product_sale_returns, allow_destroy: true

  enum money: {cash: 0, account: 1, mixed: 2}
  enum source: {sr_comment: 0, sr_operator: 1, sr_web: 2}

  attr_accessor :hour_now, :hour_start, :hour_end, :update_status, :operator, :salesman, :status_m, :status_sub, :from_status

  before_save :check_exchange
  before_save :create_log
  before_save :set_defaults
  before_save :set_balance
  after_create :set_sale_call_status
  after_save :sync_web
  after_save :send_to_channel
  after_update :set_update_values

  with_options :if => Proc.new {|m| m.update_status == nil} do
    validates_numericality_of :hour_end, greater_than: Proc.new(&:hour_start)
    validates :phone, :location_id, :money, presence: true
    validates :code, uniqueness: true
    validate :feature_rel_should_be_uniq
    validates :phone, numericality: {greater_than_or_equal_to: 70000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}
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
  with_options :if => Proc.new {|m| m.parent_id.present?} do
    validates :product_sale_returns, presence: true
  end
  with_options :if => Proc.new {|m| !m.parent_id.present? && !m.from_status.present?} do
    validates :product_sale_items, presence: true
  end

  with_options :if => Proc.new {|m| !m.update_status.present? && m.bonus.present?} do
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
    left_joins(:sale_tax)
        .where("sale_taxes.id IS#{send == "true" ? ' NOT' : ''} ?", nil) if send.present?
  }

  scope :search, ->(code_name, start, finish, phone, status, salesman_id, operator_id) {
    items = joins(:status)
    items = items.where('product_sales.phone LIKE :value', value: "%#{phone}%") if phone.present?
    items = items.joins(product_sale_items: :product)
                .where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{code_name}%").group("id") if code_name.present?
    items = items.where('product_sale_statuses.alias = ?', status) if status.present?
    items = items.where('? <= delivery_start AND delivery_start <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.joins(:salesman_travel)
                .where('salesman_travels.salesman_id = ?', salesman_id) if salesman_id.present?
    items = items.where('product_sales.approved_operator_id = ?', operator_id) if operator_id.present?
    items = items.order("product_sale_statuses.queue")
                .created_at_desc
    items
  }

  scope :by_salesman_nil, ->() {
    joins(:status)
        .where("approved_date IS NOT ? OR is_return = ?", nil, true)
        .where('product_sale_statuses.alias = ?', 'oper_confirmed')
        .where("salesman_travel_id IS ?", nil)
        .order(:approved_date)
  }

  scope :by_delivery_between, ->(date) {
    where('? <= delivery_start AND delivery_start <= ?', date, date + 1.day)
  }
  scope :by_available_time, ->(date) {
    where("delivery_start <= ?", date) if date.present?
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

  scope :report_excel, ->(start_date, end_date, salesman_id, operator_id, product_code, customer_id, order_0, order_1, order_2, order_3, status_ids) {
    items = where("product_sales.created_at >= ?", start_date.to_date)
                .where("product_sales.created_at <= ?", end_date.to_date)
    items = items.left_joins(:salesman_travel)
                .where("salesman_travels.salesman_id = ?", salesman_id) if salesman_id.present?
    items = items.where("product_sales.created_operator_id = ?", operator_id) if operator_id.present?
    items = items.left_joins(:products) if product_code.present? || customer_id.present?
    items = items.where("products.code = ?", product_code) if product_code.present?
    items = items.where("products.customer_id = ?", customer_id) if customer_id.present?
    unless order_0.present?
      qr = ""
      if order_1.present?
        qr += "product_sales.source = 2"
      end
      if order_2.present?
        qr += " OR " if qr.length > 0
        qr += "product_sales.source = 0"
      end
      if order_3.present?
        qr += " OR " if qr.length > 0
        qr += "product_sales.source = 1"
      end
      items = items.where(qr) if qr.length > 0
    end

    if status_ids.present?
      ids = []
      statuses = ProductSaleStatus.by_ids(status_ids)
      statuses.each {|status|
        ids.push status.id
        if status.next.present?
          ids += status.next.split(",").map(&:to_i)
        end
      }
      items = items.where("product_sales.status_id IN (?)", ids) if ids.length > 0
    end

    items
  }
  scope :travel_nil, ->(id) {
    items = joins(:status)
    items = if id.nil?
              items.where("salesman_travel_id IS ? AND product_sale_statuses.alias = ?", nil, 'oper_confirmed')
            else
              items.where("product_sales.id = ? OR (salesman_travel_id IS ? AND product_sale_statuses.alias = ?)", id, nil, 'oper_confirmed')
            end
    items.order(:delivery_start)
  }

  scope :with_status_logs, ->(status_id) {
    items = joins(:product_sale_status_logs)
    items = items.where("product_sale_status_logs.status_id = ?", status_id) if status_id.present?
    items
  }
  scope :with_salesman_travel, ->() {
    joins(:salesman_travel)
  }
  scope :by_travel_date, ->(start_date, end_date) {
    where('salesman_travels.created_at >= ?', start_date)
        .where('salesman_travels.created_at < ?', end_date)
  }
  scope :by_salesman_id, ->(salesman_id) {
    where('salesman_travels.salesman_id = ?', salesman_id)
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

  def delivery_hour
    "#{delivery_start.strftime('%m/%d')} #{delivery_start.hour}-#{delivery_end.hour.to_s}"
  end

  def count_product
    product_sale_items.sum(:quantity)
  end

  def bought_price
    product_sale_items
        .pluck(:bought_price)
        .sum(&:to_i)
  end

  def return_price
    product_sale_returns
        .joins(:product_sale_item)
        .pluck("product_sale_items.price * product_sale_returns.quantity")
        .sum(&:to_i)
  end

  def status_name
    if status.present?
      if parent_id.present?
        "#{status.name_with_parent} (#{parent.status.name})"
      else
        status.name_with_parent
      end
    else
      "??????????????????"
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
    # 2 ???????? ???????????????? ???????????????? ?????????? ??????????
    sales = ProductSale.by_status('sals_delivered')
                .by_phone(phone)
                .count
    sales += DirectSale.by_phone(phone)
                 .count
    sales += ProductSaleDirect.by_phone(phone)
                 .count
    if sales > 1
      product_sale_items.each(&:add_bonus)
      bonu = Bonu.by_phone(phone)
      if bonu.present?
        b = bonu.first
        ApplicationController.helpers
            .send_sms(phone, "Tanii bonus #{b.balance} tugrug bolloo. Ta daraagiin hudaldan avaltdaa ashiglah bolomjtoi. Market.mn, 77779990")
      end
    end
  end

  def remove_bonus
    product_sale_returns.each(&:remove_bonus)
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

  def travel_salesman_name
    if salesman_travel.present?
      salesman_travel.salesman.name
    else
      ""
    end
  end

  def feedback_time
    if feedback_period.present?
      h = (feedback_period / 60).to_i
      "#{h}:#{(h * 60) - feedback_period}"
    else
      ""
    end
  end

  def allocation_type
    if delivery_end.beginning_of_hour < Time.current.beginning_of_hour
      "danger"
    elsif status.alias == "oper_replacement" || status.alias == "oper_return"
      "warning"
    elsif status.alias == "auto_redistribution"
      "primary"
    else
      "default"
    end
  end

  def with_location
    "#{location.full_name} (#{delivery_hour}), #{phone}"
  end

  def is_country
    true
    location.station.present?
  end

# ???????????????????????? sms ????????????
  def sent_info_to_user
    # SendSmsJob.perform_later(phone, "Tanii zahialgiin hurgelt ehellee. #{delivery_start.hour}-#{delivery_end.hour} tsagiin hoorond hurgegdeh bolno. Ajiltan :mn, utas #{salesman_travel.salesman.phone}. Market.mn", salesman_travel.salesman.name)
  end

# ?????????? ?????? ???????? ???????????? ????????
  def has_seen_stockkeeper
    if salesman_travel_id.present?
      ProductWarehouseLoc.by_travel(salesman_travel_id).count > 0
    else
      false
    end
  end
  def update_sum_price
    sum_val = product_sale_items.by_to_see(false)
                  .sum(:sum_price)
    if bonus.present?
      bonu = Bonu.by_phone(phone)
      if bonu.present?
        b = bonu.first
        if sum_val < bonus
          self.update_column(:bonus, sum_val)
        else
          sum_val -= bonus if b.balance >= bonus
        end
      end
    end

    self.update_column(:sum_price, sum_val)
  end

  def product_names
    n = ""
    product_sale_items.each_with_index do |item, index|
      if index > 0
        n += ","
      end
      n += "#{item.product.code} #{item.product.n_name} #{item.feature_item.name}"
    end
    n
  end

  def allow_not_status
    if status.present?
      previous_alias = status.alias
      if status.previous.present?
        previous_alias = status.previous_status.alias
        previous_alias == "oper_failed"
      else
        previous_alias == "auto_redistribution" || previous_alias == "auto_redistributed" || previous_alias == "sals_delivered" || previous_alias == "auto_closed"
      end
    else
      false
    end
  end

  def clear_relation
    item_eached = false
    if salesman_travel_id.present?
      salesman = salesman_travel.salesman
      if salesman_travel_route.present?
        item_eached = true
        product_sale_items.each do |sale_item|
          ProductSaleLog.create(operator: operator,
                                salesman: salesman,
                                salesman_travel_id: salesman_travel_id,
                                product_sale_id: sale_item.product_sale_id,
                                sale_item: sale_item,
                                product_id: sale_item.product_id,
                                feature_item_id: sale_item.feature_item_id,
                                quantity: sale_item.quantity,
                                to_see: sale_item.to_see,
                                p_discount: sale_item.p_discount,
                                discount: sale_item.discount)
          sale_item.product_balance.destroy if sale_item.product_balance.present?

          warehouse_locs = ProductWarehouseLoc.by_travel(salesman_travel_id)
                               .by_feature_item_id(sale_item.feature_item_id)
          q = sale_item.quantity
          if warehouse_locs.present?
            warehouse_locs.each do |loc|
              if q > 0
                if loc.quantity <= q
                  loc.destroy
                else
                  loc.update_column(:quantity, loc.quantity - q)
                end
                q -= loc.quantity
              else
                break
              end
            end
          end
          sale_item.destroy
        end
        salesman_travel_route.destroy

      end
      self.update_column(:salesman_travel_id, nil)
    end

    unless item_eached
      product_sale_items.each(&:destroy)
    end
  end

  private

  def send_to_channel
    SalesmanTravelJob.perform_later("sale", self) if status.alias == "oper_confirmed"
  end

  def check_money
    self.errors.add(:money, " ???????????? ?????????????? ???????????? ???????? ??????????!") unless account?
  end

  def set_defaults
    self.code = ApplicationController.helpers.get_code(ProductSale.last) unless code.present?
    if operator.present?
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
          self.errors.add(:bonus, " ???????????????? ??????????!")
        elsif real_bonus > sum_price / 2
          self.errors.add(:bonus, " ?????????????? ?????????? ???????????? ???????????????? ??????????!")
        end
      else
        self.errors.add(:bonus, " ???????????????? ??????????!")
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
    if operator.present? || salesman.present?
      self.product_sale_status_logs << ProductSaleStatusLog.new(operator: operator,
                                                                salesman: salesman,
                                                                status: status,
                                                                note: status_note)
      # set_status
      if status.present?
        if status.previous.present?
          previous_alias = status.previous_status.alias
          if previous_alias == "oper_failed"
            self.clear_relation
          end
        end
        if status.next.present?
          next_status = status.next_status
          if next_status.user_type == "auto"
            self.status = next_status
          elsif sale_call.present? && (next_status.alias == "call_connect_again" || next_status.alias == "call_no_balance" || next_status.alias == "call_address_changed")
            sale_call.temp_operator = operator
            sale_call.temp_salesman = salesman
            sale_call.status = next_status
            sale_call.save(validate: false)
          end
        end
        # ?????????? ?????????????????????? ?????????????????????????????? ???????????????? ??????
        if status.alias == "oper_confirmed" && inh.present?
          if inh.status.alias == "auto_redistribution"
            sta = ProductSaleStatus.find_by_alias("auto_redistributed")
            inh.update_column(:status_id, sta.id)
          end
        end

      end
    end

  end

  def set_balance
    if bonus.present? && bonus > 0
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

# ???????????? ?????????????? ????????????
  def check_exchange
    if is_exchange
      self.is_return = product_sale_returns.present? && !product_sale_items.present?
      if sum_price < 0
        self.back_money = -sum_price
      else
        self.back_money = nil
      end
    else
      self.back_money = nil
      self.is_return = false
    end
  end

  def set_update_values
    if salesman_travel_id.present? && salesman_travel_route.present?
      salesman_travel_route.update_column(:location_id, location_id)
    end
  end

  def sync_web
    #   ???????????? ???????????????? ??????????????
    if cart_id.present?
      stat = status.alias
      if stat == "oper_confirmed" || stat == "sals_delivered"
        url = "sales/status"
        params = {id: cart_id, status: stat == "oper_confirmed" ? 3 : 4}.to_json
        ApplicationController.helpers.api_request(url, 'patch', params)
      end

      if stat == "oper_confirmed" && salesman_travel.present?
        url = "sales/salesman"
        salesman = salesman_travel.salesman
        ApplicationController.helpers.api_request(url, 'patch', params)
      end
    end
  end

  def set_sale_call_status
    if sale_call.present?
      call_status = ProductSaleStatus.find_by_alias("call_order")
      sale_call.update_column(:status_id, call_status.id)

      self.update_column(:feedback_period, ApplicationController.helpers.get_minutes(created_at, sale_call.created_at))
    end
  end
end
