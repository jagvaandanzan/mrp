class AddAliNameMnToAliCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :ali_categories, :prod, :boolean, after: 'checked', default: false
    add_column :ali_categories, :name_mn, :string, after: 'name'
    add_column :ali_filter_groups, :name_mn, :string, after: 'name'
    add_column :ali_filters, :name_mn, :string, after: 'name'
    remove_column :product_categories, :name_en, :string
    remove_column :category_filters, :name_en, :string
    remove_column :category_filter_groups, :name_en, :string
  end
end
