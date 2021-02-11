class ProductBalance < ApplicationRecord
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :product_income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :sale_item, :class_name => "ProductSaleItem", optional: true
  belongs_to :sale_direct, :class_name => "ProductSaleDirect", optional: true
  belongs_to :user, optional: true
  belongs_to :operator, optional: true

  after_save -> {sync_web}

  scope :balance, -> (product_id, feature_item_id = nil) {
    items = where(product_id: product_id)
    items = items.where(feature_item_id: feature_item_id) if feature_item_id.present?
    items.sum(:quantity)
  }

  scope :by_sale_item, -> (feature_item_id, sale_item_id) {
    where(feature_item_id: feature_item_id)
        .where(sale_item_id: sale_item_id)
  }

  scope :balance, -> (product_id, feature_item_id = nil) {
    items = where(product_id: product_id)
    items = items.where(feature_item_id: feature_item_id) if feature_item_id.present?
    items.sum(:quantity)
  }

  private

  def sync_web
    if feature_item.present?
      url = "product/balance"
      balance = ProductBalance.balance(product_id, feature_item_id)

      params = {product_id: product_id, feature_item_id: feature_item_id, balance: balance}.to_json
      ApplicationController.helpers.api_request(url, 'patch', params)
      # response =
      # Rails.logger.info("response: #{response.body}")
    end

  end
end
