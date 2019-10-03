class Location < ApplicationRecord
  belongs_to :loc_khoroo
  has_many :product_sales, :class_name => "ProductSale", :foreign_key => "location_id"


  validates :name, presence: true

  scope :search, ->(khoroo_id, sname) {
    items = where(loc_khoroo_id: khoroo_id)
    items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  scope :searchAll, ->() {
    items = where("")
    # items = items.where('name LIKE :value OR name_la LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:name)
  }

  scope :last_location, -> {
    last
  }

  def full_name
    loc_khoroo.loc_district.name + ", " + loc_khoroo.name + ", " + name
  end
end
