class BankTransaction < ApplicationRecord
  belongs_to :salesman, optional: true
  belongs_to :bank_account, optional: true
  belongs_to :dealing_account, :class_name => "BankDealingAccount", optional: true

  enum exchange: {cny: 0, usd: 1, eur: 2, rub: 3}

  with_options :if => Proc.new {|m| m.is_manual.present?} do
    validates :date, presence: true
    # validates :bank_account_id, presence: true
    # validates :dealing_account_id, presence: true
    # validates :salesman_id, presence: true
    # validates :billing_date, presence: true
    validates :summary, presence: true
    validates :summary, numericality: {greater_than: 1000, only_integer: true, message: :invalid}
  end

  with_options :if => Proc.new {|m| m.is_manual.present? && m.dealing_account_id != 4} do
    validates :value, presence: true, length: {maximum: 255}
  end

  with_options :if => Proc.new {|m| m.is_manual.present? && m.dealing_account_id == 4} do
    validates :exchange, presence: true
    validates :exc_rate, presence: true
    validates :exc_rate, numericality: {greater_than: 1, message: :invalid}
  end

  before_save :check_salesman
  before_save :set_exc_summary
  # after_create :to_logistic Тооцоо нийлэх хэлбэр өөрчлөгдсөн

  attr_accessor :is_manual, :user_id

  scope :by_day, ->(day) {
    where("date >= ?", day)
        .where("date < ?", day + 1.day)
        .order(date: :desc)
  }

  scope :by_billing, ->(day) {
    where("billing_date >= ?", day)
        .where("billing_date < ?", day + 1.day)
  }

  scope :order_date, -> {
    order(date: :desc)
  }

  scope :is_income, -> {
    where("summary > ?", 0)
  }

  scope :by_manual, -> {
    where("dealing_account_id IS ?", nil)
  }

  scope :by_salesman_id, ->(salesman_id) {
    where(salesman_id: salesman_id)
  }

  scope :sum_summary, ->() {
    sum(:summary)
  }

  scope :by_billing_date, ->(start, finish) {
    where('? <= billing_date AND billing_date <= ?', start.to_time, finish.to_time + 1.days)
  }

  scope :by_before_start, ->(start) {
    where('billing_date < ?', start.to_time)
  }

  scope :by_dalai, -> {
    where(dealing_account_id: 4)
  }

  scope :search, ->(phones, value, account, min, max, date, salesman = nil, bank_account = nil, dealing_account = nil, billing_date = nil) {
    if phones.nil?
      items = order_date
    else
      items = (where("value REGEXP ?", phones.join("|"))
                   .or(where("summary <= ?", 500000)))
                  .order_date
    end
    items = items.where('value LIKE :value', value: "%#{value}%") if value.present?
    items = items.where(account: account) if account.present?
    items = items.where("summary >= ?", min) if min.present?
    items = items.where("summary <= ?", max) if max.present?
    items = items.where('date >= ?', date)
                .where('date < ?', date + 1.day) if date.present?
    items = items.where(salesman_id: salesman) if salesman.present?
    items = items.where(bank_account_id: bank_account) if bank_account.present?
    items = items.where(dealing_account_id: dealing_account) if dealing_account.present?
    items = items.where('billing_date >= ?', billing_date)
                .where('billing_date < ?', billing_date + 1.day) if billing_date.present?
    items
  }

  def date_time
    date.strftime("%F %R")
  end

  def manual
    !first_balance.present?
  end

  def summary
    ApplicationController.helpers.get_f(self[:summary])
  end

  def t_type
    if self.manual
      if self.is_logistic
        "#{exchange_i18n}  #{ApplicationController.helpers.get_currency(exc_rate, Const::CURRENCY[6], 2)}"
      else
        2
      end
    elsif summary > 0
      1
    else
      3
    end
  end

  def is_logistic
    dealing_account_id == 4
  end

  private

  def check_salesman
    unless salesman.present?
      if value.present?
        p = value.match(/[789]\d{7}/)
        if p.present?
          self.salesman = Salesman.find_by_phone(p.to_s)
          # puts "p: #{p}"
          v = value.gsub(p.to_s, "")
          d = v.split(".")
          if d.length == 2
            m = ""
            (1..2).each do |i|
              dm = d[0][d[0].length - i]
              if dm.present? && dm.match(/[0-9]/)
                m = "#{dm}#{m}"
              end
            end
            s = ""
            (0..1).each do |i|
              if d[1][i].present? && d[1][i].match(/[0-9]/)
                s = "#{s}#{d[1][i]}"
              end
            end

            if m.present? && s.present?
              self.billing_date = Date.parse("#{Time.current.year}-#{m}-#{s}")
            end
          end
        end

      end
    end
  end

  def set_exc_summary
    if exc_rate.present?
      self.exc_summary = summary / exc_rate
    end
  end

  def to_logistic
    if self.is_logistic
      logistic = Logistic.find(1)
      product_supply_orders = ProductSupplyOrder.by_sum_price_nil
      yuan = (summary / exc_rate).round(2)
      yuan += logistic.balance if logistic.balance.present? && logistic.balance > 0

      # Rails.logger.info("yuan = #{yuan}")
      product_supply_orders.each do |supply_order|
        s = ProductSupplyOrderItem.sum_price_by_supply_order(supply_order.id)
        if s.present? && s > 0
          # Rails.logger.info("#{supply_order.id} ==>#{s}==>#{yuan - s}")
          if yuan - s >= 0
            LogisticTransaction.create(bank_transaction: self,
                                       user_id: user_id,
                                       logistic: logistic,
                                       supply_order: supply_order,
                                       exc_rate: exc_rate,
                                       summary: s)
            supply_order.update_column(:sum_price, s * exc_rate)
            yuan -= s
          end
        end
      end

      if yuan > 0
        logistic.update_column(:balance, yuan)
      end
    end
  end
end
