class BankTransaction < ApplicationRecord

  attr_accessor :it_is_new

  scope :by_day, ->(day) {
    where("date >= ?", day)
        .where("date < ?", day + 1.day)
        .order(id: :desc)
  }
end
