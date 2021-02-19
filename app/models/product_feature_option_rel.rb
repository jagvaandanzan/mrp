class ProductFeatureOptionRel < ApplicationRecord

  belongs_to :product
  belongs_to :feature_option, :class_name => "ProductFeatureOption"

  has_one :product_feature, through: :feature_option

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :by_feature_option_ids, ->(ids) {
    where("feature_option_id IN (?)", ids)
  }

  scope :by_feature_option_ids, ->(ids) {
    where("feature_option_id IN (?)", ids)
  }

  scope :by_size_feature_option, ->() {
    joins(:product_feature)
        .joins(:feature_option)
        .where("product_features.feature_type =? ", 1)
        .order('product_feature_options.queue')
        .select("product_feature_options.id, product_feature_options.name")

  }

  def by_size_feature_option11
    feature_option.each {||}
  end


  private

  def sync_web(method)
    if product.is_sync
      self.method_type = method
      url = "product/feature_option_rel"

      if method == 'delete'
        params = nil
        url += "/" + id.to_s
      else
        params = self.to_json(only: [:id, :product_id, :feature_option_id], :methods => [:method_type])
      end

      ApplicationController.helpers.api_request(url, method, params)
    end
  end

end
