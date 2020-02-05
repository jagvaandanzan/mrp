class AliCategory < ApplicationRecord
  belongs_to :ali_category, optional: true

  has_many :sub_categories, :class_name => "AliCategory", :foreign_key => "ali_category_id"
  has_many :filter_groups, :class_name => "AliFilterGroup", :foreign_key => "ali_category_id"

  scope :parent_nil, ->() {
    where("ali_category_id IS NULL")
  }

  scope :none_check, ->() {
    where(checked: false)
  }

  scope :subs_not_check, ->() {
    sub_categories.none_check.count
  }

end
