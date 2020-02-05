class AddCheckedToAliCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :ali_categories, :checked, :boolean, after: 'id', default: false
    add_reference :ali_filter_groups, :ali_category, foreign_key: true, after: 'id'
  end
end
