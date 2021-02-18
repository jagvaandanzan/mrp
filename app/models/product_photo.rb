class ProductPhoto < ApplicationRecord
  belongs_to :product

  after_save :resize_img

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  has_attached_file :photo, :path => ":rails_root/public/products/photo/:id_partition/:style.:extension", styles: {original: "1200x1200>", tumb: "400x400>"}, :url => '/products/photo/:id_partition/:style.:extension'
  validates_attachment :photo,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 4.megabytes}

  validates :photo, presence: true

  def photo_url
    photo.url
  end

  private

  def resize_img
    if self.photo.present?
      img = self.photo
      path_orig = img.queued_for_write[:original]
      path_thumb = img.queued_for_write[:tumb]
      ApplicationController.helpers.resize_image(path_orig.path) if path_orig.present?
      ApplicationController.helpers.resize_image(path_thumb.path) if path_thumb.present?
    end
  end

  def sync_web(method)
    self.method_type = method
    url = "product/photo"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id], :methods => [:method_type, :photo_url])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
