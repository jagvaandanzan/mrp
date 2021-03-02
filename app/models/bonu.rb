class Bonu < ApplicationRecord
  has_many :bonus_phones
  has_many :bonus_balances

  accepts_nested_attributes_for :bonus_phones, allow_destroy: true

  scope :order_balance, ->() {
    order(:balance)
  }

  scope :search, ->(phone, min, max) {
    items = left_joins(:bonus_phones)
    items = items.where('bonus_phones.phone = ?', phone) if phone.present?
    items = items.where('balance >= ?', min) if min.present?
    items = items.where('balance <= ?', max) if max.present?
    items.group("bonus.id")
        .order_balance
  }

  scope :by_phone, ->(phone) {
    items = left_joins(:bonus_phones)
    items = items.where('bonus_phones.phone = ?', phone) if phone.present?
    items.group("bonus.id")
  }

  def balance_sum
    BonusBalance.balance_sum(id)
  end

  def phones
    s = ""
    bonus_phones.each_with_index {|p, index|
      if index > 0
        s += ", "
      end
      s += "#{p.phone}"
    }

    s
  end

end
