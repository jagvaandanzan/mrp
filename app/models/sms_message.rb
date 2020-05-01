class SmsMessage < ApplicationRecord
  belongs_to :operator, optional: true
  belongs_to :user, optional: true

  # validates :message, presence: true, length: {maximum: 160}
  validates :amount, presence: true, numericality: {greater_than: 100, only_integer: true, message: :invalid}
  validates :recipient, numericality: {greater_than_or_equal_to: 80000000, less_than_or_equal_to: 99999999, only_integer: true, message: :invalid}

  scope :order_date, -> {
    order(created_at: :desc)
  }

  scope :search, ->(recipient, amount, date) {
    items = order_date
    items = items.where(recipient: recipient) if recipient.present?
    items = items.where(amount: amount) if amount.present?
    items = items.where('created_at >= ?', date) if date.present?
    items = items.where('created_at < ?', date + 1.day) if date.present?
    items
  }

  def full_message
    I18n.t('sms.to_customer', amount: amount)
  end
end
