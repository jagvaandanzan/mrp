class ProductInstruction < ApplicationRecord
  belongs_to :product

  enum i_type: {using: 0, installation: 1, washing: 2}

  validates_uniqueness_of :i_type, scope: [:product_id]

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :i_type, presence: true
  validate :valid_instruction

  has_attached_file :image, :path => ":rails_root/public/products/instruction/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/instruction/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  has_attached_file :video, :path => ":rails_root/public/products/instruction/video/:id_partition/:style.:extension", :url => '/products/instruction/video/:id_partition/:style.:extension'
  validates_attachment :video,
                       content_type: {content_type: ["video/mp4"], message: :content_type}, size: {less_than: 40.megabytes}

  def image_url
    if image.present?
      image.url
    end
  end

  def video_url
    if video.present?
      video.url
    end
  end

  private

  def valid_instruction
    self.errors.add(:description, :blank) if !description.present? && !image.present? && !video.present?
  end

  def sync_web(method)
    if product.is_sync
      self.method_type = method
      url = "product/instruction"

      if method == 'delete'
        params = nil
        url += "/" + id.to_s
      else

        params = self.to_json(only: [:id, :product_id, :i_type, :description], :methods => [:method_type, :image_url, :video_url])
      end

      response = ApplicationController.helpers.api_request(url, method, params)
      Rails.logger.info("response.body: #{response.body}")
    end
  end
end
