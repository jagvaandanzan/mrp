class AliCategory < ApplicationRecord
  paginates_per 10
  belongs_to :ali_category, optional: true

  has_many :sub_categories, :class_name => "AliCategory", :foreign_key => "ali_category_id"
  has_many :filter_groups, :class_name => "AliFilterGroup", :foreign_key => "ali_category_id"

  has_many :ali_filter_groups, dependent: :destroy

  accepts_nested_attributes_for :sub_categories, allow_destroy: true
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

  scope :subs_not_check, ->() {
    sub_categories.none_check.count
  }

  def check_status
    ("<i class='fa fa" + (prod ? "-check text-success" : "-times text-danger") + "' style='font-size: 16px;'></i>&nbsp;&nbsp;").html_safe
  end

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

  def has_subs?
    sub_categories.exists?
  end

  def last_depth
    if sub_categories.empty?
      self
    else
      sub_categories.map(&:last_depth).max
    end
  end

  def deep_count(prod = nil)
    count = sub_categories.check_prod(prod).count
    sub_categories.check_prod(prod).each do |subcategory|
      count += subcategory.deep_count(prod)
    end
    count
  end

  def prod_categories
    c_prod = deep_count(true)
    c_all = deep_count
    ("<span class='label label-#{c_prod==c_all ? 'success':'warning'}'>#{c_prod} / #{c_all}</span>").html_safe
  end


  def prod_filters
    groups = ali_filter_groups.count
    p_groups = ali_filter_groups.check_prod(true).count
    group_ids = ali_filter_groups.pluck(:id)
    filters = AliFilter.by_group_ids(group_ids).count
    p_filters = AliFilter.by_group_ids(group_ids).check_prod(true).count

    ("<span class='label label-#{p_groups==groups ? 'success':'warning'}'>#{p_groups} / #{groups}</span>  <span class='label label-#{p_filters==filters ? 'success':'warning'}'>#{p_filters} / #{filters}</span>").html_safe

  end

end
