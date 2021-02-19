class ProductFilterGroup < ApplicationRecord
  belongs_to :product
  belongs_to :category_filter_group
  has_many :product_filters, dependent: :destroy

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  validates :category_filter_group_id, presence: true

  scope :sync_by_p, ->(ids) {
    where("product_id IN (?)", ids)
  }

  private

  def sync_web(method)
    if product.is_sync
      self.method_type = method
      url = "product/filter_group"

      if method == 'delete'
        params = nil
        url += "/" + id.to_s
      else

        params = self.to_json(only: [:id, :product_id, :category_filter_group_id], :methods => [:method_type])
      end

      ApplicationController.helpers.api_request(url, method, params)
    end
  end
end
