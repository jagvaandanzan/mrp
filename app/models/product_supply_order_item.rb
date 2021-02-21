class ProductSupplyOrderItem < ApplicationRecord
  belongs_to :product_supply_order
  belongs_to :logistic, optional: true
  belongs_to :product, -> {with_deleted}
  has_many :supply_features, :class_name => "ProductSupplyFeature", :foreign_key => "order_item_id", dependent: :destroy
  accepts_nested_attributes_for :supply_features, allow_destroy: true

  enum status: {draft: 0, order_created: 1, ordered: 2, cost_included: 3, warehouse_received: 4, calculated: 5, clarification: 6, clarified: 7, canceled: 8}

  attr_accessor :tab_index, :cn_name
  before_save :set_cn_name

  with_options :if => Proc.new {|m| m.product_supply_order.present?} do
    validates :product_id, presence: true
  end

  with_options :if => Proc.new {|m| m.canceled?} do
    validates :note_lo, presence: true
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[product_supply_order.exchange_before_type_cast.to_i], 2)
  end

  scope :search_by_order, ->(start, finish, supply_code, product_name) {
    items = joins(:product_supply_order)
    items = items.where('? <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_supply_orders.ordered_date": :desc)
    items
  }

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(start, finish, supply_code, product_name) {
    items = left_joins(:product_supply_order)
                .where("product_supply_orders.status > ?", 0)
    if start.present? && finish.present?
      items = items.where(':start <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= :finish',
                          start: start.to_time, finish: finish.to_time + 1.days)
    end
    if supply_code.present?
      items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%")
    end
    items = items.joins(:product).where('products.code LIKE :value OR products.n_name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.created_at_desc
  }

  scope :by_status_lower, ->(stat) {
    where("status < ?", stat)
  }
  scope :sum_price_by_supply_order, ->(supply_order_id) {
    where(product_supply_order_id: supply_order_id)
        .sum(:sum_price_lo)
  }

  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

  def set_sum_price
    sum = 0
    supply_features.each do |feature|
      sum += feature.quantity * feature.price
    end

    self.update_column(:sum_price, sum.to_f.round(1))
  end

  def set_sum_price_lo
    sum = 0
    supply_features.each do |feature|
      sum += feature.quantity_lo * feature.price_lo
    end
    self.update_attribute(:sum_price_lo, sum.to_f.round(1))

    if sum > 0 && !canceled?
      self.update_columns(status: 2, purchase_date: Time.current)
      product_supply_order.update_status(2)
    end
  end

  def set_supply_feature
    if product.product_feature_items.present?
      if supply_features.count != product.product_feature_items.count
        was_feature_ids = supply_features.map(&:feature_item_id).to_a
        feature_ids = product.product_feature_items.map(&:id).to_a
        delete_ids = was_feature_ids - feature_ids
        self.supply_features.by_feature_item_ids(delete_ids).destroy_all

        (feature_ids - was_feature_ids).each do |feature_id|
          feature_item = ProductFeatureItem.find(feature_id)
          self.supply_features << ProductSupplyFeature.new(feature_item_id: feature_id,
                                                           product_id: feature_item.product_id)
        end

      end
    end
  end

  def get_order_type
    if product_supply_order.is_basic?
      I18n.t('activerecord.models.product_supply_order')
    else
      I18n.t('titles.product_sample')
    end
  end

  def purchase_stat
    q = 0
    q_lo = 0
    supply_features.each do |feature|
      q += feature.quantity if feature.quantity.present?
      q_lo += feature.quantity_lo if feature.quantity_lo.present?
    end
    "#{ApplicationController.helpers.yes_no(!order_created?)} #{q} / <b>#{q_lo}</b>"
  end

  def purchase_date
    self[:purchase_date].strftime('%F') if self[:purchase_date].present?
  end

  def shipping_er_feature
    shipping_er_features = ShippingErFeature.by_order_item_id(self.id)
    if shipping_er_features.present?
      shipping_er_feature = shipping_er_features.first
      er_product = shipping_er_feature.shipping_er_product
      shipping_er = er_product.shipping_er

      cost_text = ""
      shipping_er.shipping_er_products.each_with_index {|er, index|
        cost_text += "; " if index > 0
        cost_text += "#{er.product.full_name}"
      }
      [shipping_er.date.strftime('%F'), self.get_currency(shipping_er.cost), er_product.quantity, er_product.cargo, cost_text]
    else
      ["", "", "", "", ""]
    end
  end

  def shipping_ub_product
    shipping_ub_products = ShippingUbProduct.by_product_id(self.product_id)
    if shipping_ub_products.present?
      date = shipping_ub_products.first.shipping_ub.date.strftime('%F')
      costs = 0
      cost_text = ""
      loaded = 0
      cargo = 0
      shipping_ub_products.each_with_index {|er, index|
        costs += er.cost
        loaded += er.quantity if er.quantity.present?
        cargo += er.cargo if er.cargo.present?
        cost_text += "; " if index > 0
        cost_text += "#{er.product.full_name}"
      }
      [date, self.get_currency(costs), loaded, cargo, cost_text]
    else
      ["", "", "", "", ""]
    end
  end

  def set_status(status)
    self.update_column(:status, status) if status > ProductSupplyOrderItem.statuses[self.status]
  end

  private

  def set_cn_name
    product.update_column(:c_name, cn_name) if cn_name.present? && product.name != cn_name
    product_supply_order.update_column(:status, 8) if canceled?
  end
end
