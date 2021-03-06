class ProductSampleImage < ApplicationRecord
  belongs_to :product_supply_order
  has_many :product_supply_order_items, through: :product_supply_order

  has_attached_file :image, :path => ":rails_root/public/product_sample/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/product_sample/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  validates :image, presence: true

  scope :by_product_id, ->(id) {
    left_joins(:product_supply_order_items)
        .where("product_supply_order_items.product_id = ?", id)
  }

end
