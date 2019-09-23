class ProductCategory < ApplicationRecord
  acts_as_paranoid

  has_many :children, :class_name => "ProductCategory", :foreign_key => "parent_id"
  belongs_to :parent, -> { with_deleted }, :class_name => "ProductCategory", optional: true

  has_many :products, :class_name => "Product", :foreign_key => "category_id"

  validates :name, :code, presence: true
  validates :code, uniqueness: true

  scope :search, ->(p_id) {
    items = where(parent_id: p_id)
    items.order(:name)
  }

  scope :top_level, ->() {
    items = where(parent_id: nil)
    items.order(:name)
  }


  scope :get_children, ->(p_id) {
    if p_id.presence
      items = where(parent_id: p_id)
    else
      items = where(parent_id: nil)
    end

    items.order(:name)
  }

end
