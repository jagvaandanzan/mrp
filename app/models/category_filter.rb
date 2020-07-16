class CategoryFilter < ApplicationRecord
  belongs_to :category_filter_group

  after_create -> {sync_web('post')}, if: Proc.new {self.category_filter_group.persisted?}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :name, presence: true
  validates_uniqueness_of :name, scope: [:category_filter_group_id]

  scope :order_name, ->() {
    order(:name)
  }

  scope :by_group, ->(ids) {
    where('category_filter_group_id IN (?)', ids)
        .pluck("DISTINCT name_en")
  }

  has_attached_file :img, :path => ":rails_root/public/products/category/:id_partition/:style.:extension", styles: {original: "270x270>"}, :url => '/products/category/:id_partition/:style.:extension'
  validates_attachment :img,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png", "image/webp"], message: :content_type}, size: {less_than: 1.megabytes}

  def img_url
    if img.present?
      img.url
    end
  end

  private

  def sync_web(method)
    self.method_type = method
    url = "categories/filter"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type, :img_url], only: [:id, :category_filter_group_id, :name, :name_en])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    Rails.logger.info("#{response.body}")
    if response.code.to_i == 201
      self.update(sync_at: Time.now, method_type: 'sync')
    end
  end
end
