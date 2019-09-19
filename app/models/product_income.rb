class ProductIncome < ApplicationRecord
  belongs_to :supplier, -> { with_deleted }, :class_name => "ProductSupplier", :foreign_key => "supplier_id"

  validates :code, :supplier_id, presence: true

  scope :income_date_desc, -> {
    order(income_date: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = income_date_desc
    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('income_date >= :s AND income_date <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    items
  }
end
