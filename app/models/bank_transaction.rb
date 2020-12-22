class BankTransaction < ApplicationRecord
  belongs_to :salesman, optional: true
  belongs_to :bank_account, optional: true
  belongs_to :dealing_account, :class_name => "BankDealingAccount", optional: true

  with_options :if => Proc.new {|m| m.is_manual.present?} do
    validates :salesman_id, presence: true
    validates :bank_account_id, presence: true
    validates :dealing_account_id, presence: true
    validates :billing_date, presence: true
    validates :value, presence: true, length: {maximum: 255}
    validates :summary, presence: true
    validates :summary, numericality: {greater_than: 1000, only_integer: true, message: :invalid}
  end

  before_save :check_salesman

  attr_accessor :it_is_new, :is_manual

  scope :by_day, ->(day) {
    where("date >= ?", day)
        .where("date < ?", day + 1.day)
        .order(id: :desc)
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
    items = items.where(salesman_id: salesman) unless salesman.nil?
    items = items.where(bank_account_id: bank_account) unless bank_account.nil?
    items = items.where(dealing_account_id: dealing_account) unless dealing_account.nil?
    items = items.where('billing_date >= ?', billing_date)
                .where('billing_date < ?', billing_date + 1.day) unless billing_date.nil?
    items
  }

  def date_time
    date.strftime("%F %R")
  end

  def manual
    dealing_account.present?
  end

  private

  def check_salesman
    unless dealing_account.present?
      if value.present?
        p = value.match(/[789]\d{7}/)
        if p.present?
          self.salesman = Salesman.find_by_phone(p.to_s)
          puts "p: #{p}"
          v = value.gsub(p.to_s, "")
          d = v.split(".")
          if d.length == 2
            m = ""
            (1..2).each do |i|
              if d[0][d[0].length - i].match(/[0-9]/)
                m = "#{d[0][d[0].length - i]}#{m}"
              end
            end
            s = ""
            (0..1).each do |i|
              if d[1][i].match(/[0-9]/)
                s = "#{s}#{d[1][i]}"
              end
            end

            if m.present? && s.present?
              self.billing_date = Date.parse("#{Time.current.year}-#{m}-#{s}")
            end
          end
        else
          puts "not phone"
        end

      end
    end
  end
end
