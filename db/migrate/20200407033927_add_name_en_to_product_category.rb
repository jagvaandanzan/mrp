class AddNameEnToProductCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :product_categories, :name_en, :string, after: 'name'
    add_column :category_filter_groups, :name_en, :string, after: 'name'
    add_column :category_filters, :name_en, :string, after: 'name'
    add_attachment :category_filters, :img, after: 'name_en'
    add_reference :category_filter_groups, :product_category, foreign_key: true, after: 'id'
  end
end
