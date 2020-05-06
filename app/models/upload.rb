class Upload < ApplicationRecord

  has_attached_file :image, :path => ":rails_root/public/upload/:id_partition/:style.:extension", styles: {original: "800x800>"}, :url => '/upload/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/jpg", "image/x-png", "image/png"], message: :content_type}

end
