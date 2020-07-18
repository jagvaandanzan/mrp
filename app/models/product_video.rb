class ProductVideo < ApplicationRecord
  belongs_to :product

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  has_attached_file :video, :path => ":rails_root/public/product_videos/video/:id_partition/:style.:extension", :url => '/product_videos/video/:id_partition/:style.:extension'
  validates_attachment :video,
                       content_type: {content_type: ["video/mp4"], message: :content_type}, size: {less_than: 10.megabytes}

  validates :video, presence: true

  def video_url
    video.url
  end

  private

  def sync_web(method)
    self.method_type = method
    url = "product/video"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id], :methods => [:method_type, :video_url])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
