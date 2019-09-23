class ProductLocation < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductLocation", :foreign_key => "parent_id"
  belongs_to :parent, -> { with_deleted }, :class_name => "ProductLocation", optional: true
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "location_id"

  validates :name, :code, presence: true
  validates :code, uniqueness: true


  scope :search, ->(p_id) {
    if p_id.present?
      items = where(parent_id: p_id)
    else
      items = where(parent_id: nil)
    end

    items.order(:name)
  }

  def name_with_code
    "#{self.code} - #{self.name}"
  end
end
