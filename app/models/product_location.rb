class ProductLocation < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductLocation", :foreign_key => "parent_id"
  belongs_to :parent, -> { with_deleted }, :class_name => "ProductLocation", optional: true

  validates :name, :code, presence: true

  scope :search, ->(p_id) {
    if p_id.present?
      items = where(parent_id: p_id)
    else
      items = where(parent_id: nil)
    end

    items.order(:name)
  }
end
