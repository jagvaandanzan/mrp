class BankDealingAccount < ApplicationRecord

  validates :name, presence: true, length: {maximum: 255}
  validates :code, presence: true

  scope :order_by_name, -> {
    order(:name)
  }
  scope :search, ->(scode,sname,saccount) {
    items = order_by_name
    items = items.where('code = ?', scode) if scode.present?
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items = items.where('account LIKE :value', value: "%#{saccount}%") if saccount.present?
    items
  }
  def full_name
    "#{code} - #{name}"
  end

end
