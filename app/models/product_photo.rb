class ProductPhoto < ApplicationRecord
  belongs_to :product

  has_attached_file :photo, :path => ":rails_root/public/products/photo/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/photo/:id_partition/:style.:extension'
  validates_attachment :photo,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  validates :photo, presence: true

end
