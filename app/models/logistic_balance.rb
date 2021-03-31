class LogisticBalance < ApplicationRecord
  belongs_to :logistic
  belongs_to :product_income_item

  scope :by_start_date, ->(start) {
    where('? <= date', start.to_time)
  }

  scope :by_finish_date, ->(finish) {
    where('date <= ?', finish.to_time + 1.day)
  }

  scope :by_before_start, ->(start) {
    where('date < ?', start.to_time)
  }

  scope :sum_price, ->() {
    sum(:price)
  }
end
