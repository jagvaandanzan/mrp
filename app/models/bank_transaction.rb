class BankTransaction < ApplicationRecord

  attr_accessor :it_is_new
  after_create_commit { BankTransactionJob.perform_later self }

  def date_time
    date.strftime("%F %R")
  end

  scope :by_day, ->(day) {
    where("date >= ?", day)
        .where("date < ?", day + 1.day)
        .order(id: :desc)
  }

  scope :order_date, -> {
    order(date: :desc)
  }

  scope :search, ->(phones, value, account, min, max, date) {
    if phones.present?
      items = (where("value REGEXP ?", phones.join("|"))
                   .or(where("summary <= ?", 500000)))
                  .order_date
    else
      items = order_date
    end
    items = items.where('value LIKE :value', value: "%#{value}%") if value.present?
    items = items.where(account: account) if account.present?
    items = items.where("summary >= ?", min) if min.present?
    items = items.where("summary <= ?", max) if max.present?
    items = items.where('date >= ?', date) if date.present?
    items = items.where('date < ?', date + 1.day) if date.present?
    items
  }
end
