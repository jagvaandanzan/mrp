class ProductSpecification < ApplicationRecord
  belongs_to :product
  belongs_to :spec_item, :class_name => "TechnicalSpecItem"

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates_uniqueness_of :spec_item_id, scope: [:product_id]

  validates :specification, presence: true, length: {maximum: 255}
  validates :spec_item_id, presence: true

  scope :by_spec_item_id, ->(spec_item_id) {
    where(spec_item_id: spec_item_id)
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "product/specification"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id, :spec_item_id, :specification], :methods => [:method_type])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end

end
