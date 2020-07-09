class ProductSupplyOrderItem < ApplicationRecord
  belongs_to :product_supply_order, optional: true
  belongs_to :product_sample, optional: true
  belongs_to :logistic, optional: true
  belongs_to :product, -> {with_deleted}
  has_many :income_items, :class_name => "ProductIncomeItem", :foreign_key => "supply_order_item_id", dependent: :destroy
  has_many :supply_features, :class_name => "ProductSupplyFeature", :foreign_key => "order_item_id", dependent: :destroy
  accepts_nested_attributes_for :supply_features, allow_destroy: true

  enum status: {order_created: 0, ordered: 1, cost_included: 2, warehouse_received: 3, calculated: 4, clarification: 5, clarified: 6, canceled: 7}

  attr_accessor :tab_index

  with_options :if => Proc.new {|m| m.product_supply_order.present?} do
    validates :product_id, presence: true
  end

  def get_currency(value)
    ApplicationController.helpers.get_currency(value, Const::CURRENCY[get_model.exchange_before_type_cast.to_i], 0)
  end

  scope :search_by_sample, ->(start, finish, supply_code, product_name) {
    items = joins(:product_sample)
    items = items.where('? <= product_samples.ordered_date AND product_samples.ordered_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_samples.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_samples.ordered_date": :desc)
    items
  }

  scope :search_by_order, ->(start, finish, supply_code, product_name) {
    items = joins(:product_supply_order)
    items = items.where('? <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= ?', start.to_time, finish.to_time + 1.days) if start.present? && finish.present?
    items = items.where('product_supply_orders.code LIKE :value', value: "%#{supply_code}%") if supply_code.present?
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.order("product_supply_orders.ordered_date": :desc)
    items
  }

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(start, finish, supply_code, product_name) {
    items = left_joins(:product_sample)
                .left_joins(:product_supply_order)
    if start.present? && finish.present?
      items = items.where('(product_samples.id IS NULL AND :start <= product_supply_orders.ordered_date AND product_supply_orders.ordered_date <= :finish) OR
                            (product_supply_orders.id IS NULL AND :start <= product_samples.ordered_date AND product_samples.ordered_date <= :finish)',
                          start: start.to_time, finish: finish.to_time + 1.days)
    end
    if supply_code.present?
      items = items.where('(product_samples.id IS NULL AND product_supply_orders.code LIKE :value) OR (product_supply_orders.id IS NULL AND product_samples.code LIKE :value)', value: "%#{supply_code}%")
    end
    items = items.joins(:product).where('products.code LIKE :value OR products.name LIKE :value', value: "%#{product_name}%") if product_name.present?
    items.created_at_desc
  }

  scope :by_status_lower, ->(stat) {
    where("status < ?", stat)
  }

  def product_name_with_code
    "#{self.product.code} - #{self.product.name}"
  end

  def set_sum_price
    sum = 0
    supply_features.each do |feature|
      sum += feature.quantity * feature.price
    end

    self.update_attributes(sum_price: sum.to_f.round(1))
  end

  def set_sum_price_lo
    sum = 0
    supply_features.each do |feature|
      sum += feature.quantity_lo * feature.price_lo
    end
    self.update_attribute(:sum_price_lo, sum.to_f.round(1))

    if sum > 0
      self.update_attributes(status: 1, purchase_date: Time.current)
      if product_sample.present?
        product_sample.update_status(1)
      else
        product_supply_order.update_status(1)
      end
    end
  end

  def set_supply_feature
    if product.product_feature_items.present?
      if supply_features.count != product.product_feature_items.count
        self.supply_features.destroy_all
        product.product_feature_items.each {|feature_item|
          self.supply_features << ProductSupplyFeature.new(feature_item: feature_item)
        }
      end
    end
  end

  def get_order_type
    if product_sample.present?
      I18n.t('activerecord.attributes.product_supply_order_item.product_sample_id')
    else
      I18n.t('activerecord.attributes.product_supply_order_item.product_supply_order_id')
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

  private

  def get_model
    if product_supply_order.present?
      product_supply_order
    else
      product_sample
    end
  end

end
