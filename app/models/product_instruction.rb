class ProductInstruction < ApplicationRecord
  belongs_to :product

  enum i_type: {using: 0, installation: 1, washing: 2}

  validates_uniqueness_of :i_type, scope: [:product_id]

  validates :i_type, presence: true
  validate :valid_instruction

  has_attached_file :image, :path => ":rails_root/public/products/instruction/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/instruction/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  has_attached_file :video, :path => ":rails_root/public/products/instruction/video/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/instruction/video/:id_partition/:style.:extension'
  validates_attachment :video,
                       content_type: {content_type: ["video/mp4"], message: :content_type}, size: {less_than: 10.megabytes}

  private

  def valid_instruction
    self.errors.add(:description, :blank) if !description.present? && !file.present?
  end
end
