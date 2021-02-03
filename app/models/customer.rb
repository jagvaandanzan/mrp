class Customer < ApplicationRecord
  acts_as_paranoid

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  has_attached_file :logo, :path => ":rails_root/public/customer/logo/:id_partition/:style.:extension", styles: {original: "700x240>", tumb: "230x80>"}, :url => '/customer/logo/:id_partition/:style.:extension'
  validates_attachment :logo,
                       content_type: {content_type: ["image/jpeg", "image/x-png", "image/png"], message: :content_type}, size: {less_than: 3.megabytes}

  enum c_type: {is_organization: 0, is_individual: 1}

  validates :name, presence: true, length: {maximum: 255}
  validates :c_type, :code, :queue, presence: true

  scope :order_by_name, -> {
    order(:queue)
        .order(:name)
  }

  scope :search, ->(sname) {
    items = order_by_name
    items = items.where('name LIKE :value OR code LIKE :value', value: "%#{sname}%") if sname.present?
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
    url = "resources/customer"
    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type, :logo_url], only: [:id, :c_type, :code, :queue, :name, :description])
    end

    response = ApplicationController.helpers.api_request(url, method, params)
    # Rails.logger.info("#{response.body}")
    if response.code.to_i == 201
      self.update_attributes(sync_at: Time.now, method_type: 'sync')
    end
  end

end
