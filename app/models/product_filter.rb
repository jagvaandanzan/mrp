class ProductFilter < ApplicationRecord
  belongs_to :product
  belongs_to :product_filter_group, optional: true
  belongs_to :category_filter

  validates :category_filter_id, presence: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :by_filter_ids, ->(filter_ids) {
    where("category_filter_id IN (?)", filter_ids)
  }
  scope :sync_by_p, ->(ids) {
    where("product_id IN (?)", ids)
  }
  private

  def sync_web(method)
    self.method_type = method
    url = "product/filter"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id, :product_filter_group_id, :category_filter_id], :methods => [:method_type])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
