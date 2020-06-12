class ProductVideo < ApplicationRecord
  belongs_to :product

  has_attached_file :video, :path => ":rails_root/public/product_videos/video/:id_partition/:style.:extension", :url => '/product_videos/video/:id_partition/:style.:extension'
  validates_attachment :video,
                       content_type: {content_type: ["video/mp4"], message: :content_type}, size: {less_than: 10.megabytes}

  validates :video, presence: true
end
