class AliCategory < ApplicationRecord
  belongs_to :ali_category, optional: true

  has_many :sub_categories, :class_name => "AliCategory", :foreign_key => "ali_category_id"
  has_many :filter_groups, :class_name => "AliFilterGroup", :foreign_key => "ali_category_id"

  has_many :ali_filter_groups, dependent: :destroy
  accepts_nested_attributes_for :ali_filter_groups, allow_destroy: true

  validates :name_mn, presence: true, on: :update

  scope :parent_nil, ->() {
    where("ali_category_id IS NULL")
  }

  scope :none_check, ->() {
    where(checked: false)
  }
  scope :is_check, ->() {
    where(checked: true)
  }
  scope :check_prod, ->(prod) {
    where(prod: prod) if prod.present?
  }

  scope :by_name, ->(name) {
    where('name LIKE :value OR name_mn LIKE :value', value: "%#{name}%") if name.present?
  }

  scope :name_mn_nil, ->() {
    where("name_mn IS ?", nil)
  }

  scope :subs_not_check, ->() {
    sub_categories.none_check.count
  }

  def check_status
    ("<i class='fa fa" + (prod ? "-check text-success" : "-times text-danger") + "' style='font-size: 18px;'></i>").html_safe
  end

  scope :subs_not_check, ->() {
    sub_categories.none_check.count
  }

  def full_name
    "#{name}, #{name_mn}"
  end

  def parents
    array = []
    get_parent(self, array)
  end

  def get_parent(category, array)
    array << category

    if category.ali_category.present? && category.ali_category.checked
      get_parent(category.ali_category, array)
    else
      array
    end
  end

end
