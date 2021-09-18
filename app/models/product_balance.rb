class ProductBalance < ApplicationRecord
  belongs_to :product
  belongs_to :feature_item, :class_name => "ProductFeatureItem"
  belongs_to :income_item, :class_name => "ProductIncomeItem", optional: true
  belongs_to :sale_item, :class_name => "ProductSaleItem", optional: true
  belongs_to :sale_direct, :class_name => "ProductSaleDirect", optional: true
  belongs_to :salesman_return, optional: true
  belongs_to :transfer_item, :class_name => "StoreTransferItem", optional: true
  belongs_to :direct_sale_item, optional: true
  belongs_to :user, optional: true
  belongs_to :operator, optional: true

  after_save -> {sync_web}

  scope :balance_sum, -> (product_id, feature_item_id = nil) {
    items = where(product_id: product_id)
    items = items.where(feature_item_id: feature_item_id) if feature_item_id.present?
    items.sum(:quantity)
  }

  scope :by_sale_item, -> (feature_item_id, sale_item_id) {
    where(feature_item_id: feature_item_id)
        .where(sale_item_id: sale_item_id)
  }

  scope :by_feature_id, -> (feature_item_id, start, finish) {
    where(feature_item_id: feature_item_id)
        .where('product_balances.created_at >= :s AND product_balances.created_at <= :f', s: "#{start}", f: "#{finish + 1.day}")
        .order(created_at: :desc)
  }

  scope :balance_by_feature_id, -> (feature_item_id, date) {
    where(feature_item_id: feature_item_id)
        .where("created_at < ?", date)
        .sum(:quantity)
  }

  private

  def sync_web
    product.update_column(:balance, product.balance_sum)
    feature_item.update_column(:balance, feature_item.balance_sum) if feature_item.present?

    if product.is_sync
      if feature_item.present?
        url = "product/balance"

        params = {product_id: product_id, feature_item_id: feature_item_id, balance: feature_item.balance, price: feature_item.price}.to_json
        ApplicationController.helpers.api_request(url, 'patch', params)
        # response =
        # Rails.logger.info("response: #{response.body}")
      end
    end
  end
end
