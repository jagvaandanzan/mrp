class ProductSample < ApplicationRecord
  acts_as_paranoid

  belongs_to :supplier, -> {with_deleted}, :class_name => "ProductSupplier"
  belongs_to :user

  has_many :product_sample_images
  has_many :product_supply_order_items

  accepts_nested_attributes_for :product_sample_images, allow_destroy: true

  enum payment: {belneer: 0, zeeleer: 1}
  enum status: {order_created: 0, ordered: 1, cost_included: 2, warehouse_received: 3, calculated: 4, clarification: 5, clarified: 6, canceled: 7}
  enum exchange: {cny: 0, usd: 1, eur: 2, rub: 3, jpy: 4, gbr: 5, mnt: 6}

  attr_accessor :tab_index, :product_name, :option_rels

  validates :product_name, presence: true, length: {maximum: 255}
  validates :supplier_id, :code, :exchange, :link, presence: true
  validates :code, uniqueness: true

  with_options :if => Proc.new {|m| m.tab_index.to_i == 0} do
    before_save :set_product
  end

  scope :created_at_desc, -> {
    order(created_at: :desc)
  }

  scope :search, ->(code, start, finish) {
    items = created_at_desc
    items = items.where('code LIKE :value', value: "%#{code}%") if code.present?
    items = items.where('ordered_date >= :s AND ordered_date <= :f', s: "#{start}", f: "#{finish}") if start.present? && finish.present?
    items
  }

  def exchange_value
    ApplicationController.helpers.get_f(self[:exchange_value])
  end

  def get_product
    if self.product_supply_order_items.present?
      product_supply_order_item = self.product_supply_order_items.first
      product_supply_order_item.product
    end
  end

  private

  def set_product
    if option_rels.present?
      if product_supply_order_items.present?
        product = get_product
        product.option_rels = option_rels
        product.name_en = product_name
        product.save
      else
        product = Product.new(draft: true,
                              name_en: product_name,
                              code: ApplicationController.helpers.get_code(Product.last),
                              option_rels: option_rels)

        self.product_supply_order_items << ProductSupplyOrderItem.new(product: product)
      end
    end
  end

end
