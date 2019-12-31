class CategoryFilter < ApplicationRecord
  belongs_to :category_filter_group

  validates_uniqueness_of :name, scope: [:category_filter_group_id]
  validates :name, presence: true

end
