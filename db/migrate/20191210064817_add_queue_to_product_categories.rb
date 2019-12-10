class AddQueueToProductCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :product_categories, :queue, :integer, after: 'id', default: 0
  end
end
