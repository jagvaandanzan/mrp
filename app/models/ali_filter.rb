class AliFilter < ApplicationRecord
  belongs_to :ali_filter_group

  with_options :if => Proc.new {|m| m.img == nil} do
    validates :name_mn, presence: true, on: :update
  end

  scope :by_name, ->(name) {
    where(name: name) if name.present?
  }

  scope :name_mn_nil, ->() {
    where("name IS NOT ?", nil)
        .where("name_mn IS ?", nil)
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
  scope :by_group_ids, ->(ids) {
    where("ali_filter_group_id IN (?)", ids)
  }
end
