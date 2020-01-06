class SalesmanTravelSign < ApplicationRecord
  belongs_to :salesman_travel
  belongs_to :user

  has_attached_file :given, :path => ":rails_root/public/signature/:id_partition/given/:style.:extension", styles: {original: "600x600>"}, :url => '/signature/:id_partition/given/:style.:extension'
  validates_attachment :given,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 2.megabytes}

  has_attached_file :received, :path => ":rails_root/public/signature/:id_partition/received/:style.:extension", styles: {original: "600x600>"}, :url => '/signature/:id_partition/received/:style.:extension'
  validates_attachment :received,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 2.megabytes}

end
