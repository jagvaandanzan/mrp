class LogStat < ApplicationRecord

  scope :order_queue, ->() {
    order(:queue)
  }
end
