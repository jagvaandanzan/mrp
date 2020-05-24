class Brand < ApplicationRecord
  validates :name, presence: true, length: {maximum: 255}
  validates :logo, presence: true

  has_attached_file :logo, :path => ":rails_root/public/brands/logo/:id_partition/:style.:extension", styles: {original: "800x800>", tumb: "300x300>"}, :url => '/brands/logo/:id_partition/:style.:extension'
  validates_attachment :logo,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 3.megabytes}

  scope :order_name, ->() {
    order(:name)
  }

  scope :search, ->(search_name) {
    items = order_name
    items = items.where('name LIKE :value', value: "%#{search_name}%") if search_name.present?
    items
  }
end
