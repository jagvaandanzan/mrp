class BonusBalance < ApplicationRecord
  belongs_to :bonu
  belongs_to :product_sale, optional: true
  belongs_to :product_sale_item, optional: true
  belongs_to :direct_sale_item, optional: true

  after_save -> {sync_web}

  scope :balance_sum, -> (bonu_id) {
    items = where(bonu_id: bonu_id)
    items.sum(:bonus)
  }

  scope :balance_by_item, -> (item_ids) {
    items = where("product_sale_item_id IN (?)", item_ids)
    items.sum(:bonus)
  }

  private

  def sync_web
    bal = bonu.balance_sum
    bonu.update_column(:balance, bal)

    # url = "sales/bonus"
    # cart_id = product_sale.present? && product_sale.cart_id.present? ? product_sale.cart_id : 0
    # params = {phones: bonu.bonus_phones.map(&:phone).to_a, balance: bonus, bonus: bal, cart_id: cart_id}.to_json
    # ApplicationController.helpers.api_request(url, 'patch', params)
  end
end
