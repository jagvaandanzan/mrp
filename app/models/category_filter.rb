class CategoryFilter < ApplicationRecord
  belongs_to :category_filter_group

  # validates_uniqueness_of :name, scope: [:category_filter_group_id]
  # validates :name, presence: true


  has_attached_file :img, :path => ":rails_root/public/products/category/:id_partition/:style.:extension", styles: {original: "270x270>"}, :url => '/products/category/:id_partition/:style.:extension'
  validates_attachment :img,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png", "image/webp"], message: :content_type}, size: {less_than: 1.megabytes}

end