class Brand < ApplicationRecord
  validates :name, presence: true, length: {maximum: 255}
  validates :logo, presence: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  has_attached_file :logo, :path => ":rails_root/public/brands/logo/:id_partition/:style.:extension", styles: {original: "800x800>", tumb: "300x300>"}, :url => '/brands/logo/:id_partition/:style.:extension'
  validates_attachment :logo,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 3.megabytes}

  scope :order_name, ->() {
    order(:name)
  }

  scope :search, ->(search_name) {
    items = order_name
    items = items.where('name LIKE :value', value: "%#{search_name}%") if search_name.present?
    items
  }

  def logo_url
    if logo.present?
      logo.url
    end
  end

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/brand"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type, :logo_url], only: [:id, :name])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    if response.code.to_i == 201
      self.update(sync_at: Time.now, method_type: 'sync')
    end
  end

end
