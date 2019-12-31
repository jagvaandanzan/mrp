class ProductCategoryFilter < ApplicationRecord
  belongs_to :product_category
  belongs_to :category_filter_group
end
