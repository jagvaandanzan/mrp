class FbComment < ApplicationRecord

  validates :reply_text, presence: true, on: :update

  attr_accessor :reply_text

  scope :by_post_id, ->(post_id) {
    where(post_id: post_id)
  }

  scope :by_comment_id, ->(comment_id) {
    where(comment_id: comment_id)
  }

  scope :order_date, -> {
    order(:date)
  }

  scope :search, ->(user_name, message, date) {
    items = order_date
    items = items.where('user_name LIKE :value', value: "%#{user_name}%") if user_name.present?
    items = items.where('message LIKE :value', value: "%#{message}%") if message.present?
    items = items.where('date >= ?', date) if date.present?
    items = items.where('date < ?', date + 1.day) if date.present?
    items
  }

end
