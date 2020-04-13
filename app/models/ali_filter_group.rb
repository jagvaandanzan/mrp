class AliFilterGroup < ApplicationRecord
  belongs_to :ali_category

  has_many :filters, :class_name => "AliFilter", :foreign_key => "ali_filter_group_id"

  has_many :ali_filters, dependent: :destroy
  accepts_nested_attributes_for :ali_filters, allow_destroy: true

  validates :name_mn, presence: true, on: :update

  scope :by_name, ->(name) {
    where(name: name) if name.present?
  }

  scope :name_mn_nil, ->() {
    where("name_mn IS ?", nil)
  }

  scope :name_mn_not_nil, ->() {
    where("name_mn IS NOT ?", nil)
  }

  scope :mn_change, ->(bool) {
    where(mn_change: bool)
  }

  scope :order_by, ->() {
    order(mn_change: :desc)
  }
  scope :check_prod, ->(prod) {
    where(prod: prod) if prod.present?
  }
end
