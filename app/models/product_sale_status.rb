class ProductSaleStatus < ApplicationRecord

  has_many :product_sales, :class_name => "ProductSale", :foreign_key => "status_id"
  has_many :product_sale_status_logs, :class_name => "ProductSaleStatusLog", :foreign_key => "status_id"

  validates :name, :alias, presence: true
  validates :alias, uniqueness: true


  scope :by_previous, ->(id = nil) {
    if id.nil?
      where('previous IS ?', nil)
    else
      where('previous = ?', id.to_s)
    end
  }
  scope :skip_id, ->(id) {
    where.not(id: id)
  }
  scope :by_types, ->(user_types) {
    where('user_type IN (?)', user_types)
  }
  scope :not_types, ->(user_types) {
    where('user_type NOT IN (?)', user_types)
  }
  scope :by_type, ->(user_type, id = nil) {
    if id.nil?
      items = where('user_type = ?', user_type)
    else
      items = where('user_type = ?', user_type)
                  .or(where(id: id))
    end
    items.order(:queue)
  }

  scope :by_ids, ->(ids) {
    where('id IN (?)', ids)
  }

  scope :by_aliases, ->(aliases) {
    where('alias IN (?)', aliases)
  }

  scope :get_statuses, ->(user_type) {
    grouped_options = []
    items = where("user_type LIKE :value", value: "%#{user_type}%")
                .where("parent_id IS NULL")

    items.each do |item|
      grouped_options.push(
          [item.name, item.get_status_childs(user_type)])
    end

    grouped_options
  }

  def get_status_childs(user_type)
    ProductSaleStatus.
        where("user_type LIKE :value", value: "%#{user_type}%")
        .where("parent_id = ?", self.id)
        .map {|i| i.name}
  end

  def previous_status
    ProductSaleStatus.find(self.previous)
  end

  def next_status
    ProductSaleStatus.find(self.next)
  end

  def name_with_parent
    if self.previous.present?
      if previous_status.alias == "sals_delivered"
        previous_status.name
      else
        (self.previous.present? ? self.previous_status.name + " >> " : "") + self.name
      end
    else
      self.name
    end
  end

end
