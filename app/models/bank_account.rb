class BankAccount < ApplicationRecord

  validates :name, :account, presence: true, length: {maximum: 255}
  validates :code, presence: true

  scope :order_by_name, -> {
    order(:name)
  }

  scope :order_code, -> {
    order(:code)
  }

  scope :search, ->(scode,sname,sname_en,saccount) {
    items = order_by_name
    items = items.where('code = ?', scode) if scode.present?
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items = items.where('name_en LIKE :value', value: "%#{sname_en}%") if sname_en.present?
    items = items.where('account LIKE :value', value: "%#{saccount}%") if saccount.present?
    items
  }
  def full_name
    "#{code} - #{name}"
  end

  def account_name
    "#{name} #{account}"
  end

end
