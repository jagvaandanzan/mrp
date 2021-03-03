class BonusBalance < ApplicationRecord
  belongs_to :bonu
  belongs_to :product_sale, optional: true
  belongs_to :product_sale_item, optional: true

  after_save -> {sync_web}

  scope :balance_sum, -> (bonu_id) {
    items = where(bonu_id: bonu_id)
    items.sum(:bonus)
  }

  scope :balance_by_item, -> (item_ids) {
    items = where("product_sale_item_id IN (?)",item_ids)
    items.sum(:bonus)
  }

  private

  def sync_web
    bonu.update_column(:balance, bonu.balance_sum)
  end
end