class ProductVideo < ApplicationRecord
  belongs_to :product

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  has_attached_file :image, :path => ":rails_root/public/product_videos/image/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/product_videos/image/:id_partition/:style.:extension'
  validates_attachment :image,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  has_attached_file :video, :path => ":rails_root/public/product_videos/video/:id_partition/:style.:extension", :url => '/product_videos/video/:id_partition/:style.:extension'
  validates_attachment :video,
                       content_type: {content_type: ["video/mp4"], message: :content_type}, size: {less_than: 20.megabytes}

  validates :image, :video, presence: true

  def image_url
    image.url
  end

  def video_url
    video.url
  end

  scope :sync_by_p, ->(ids) {
    where("product_id IN (?)", ids)
  }

  # private

  def sync_web(method)
    self.method_type = method
    url = "product/video"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id], :methods => [:method_type, :image_url, :video_url])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
