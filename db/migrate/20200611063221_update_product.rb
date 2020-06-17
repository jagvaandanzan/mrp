class UpdateProduct < ActiveRecord::Migration[5.2]
  def change
    # add_reference :product_size_instructions, :product_feature_option, foreign_key: true, after: 'product_id'
    # add_column :product_categories, :is_clothes, :boolean, after: 'parent_id'
    # remove_attachment :product_feature_items, :video
    # add_attachment :products, :picture, after: 'gift_wrap'
    #
    # remove_column :products, :product_size, :string
    # remove_column :products, :package_size, :string
    # remove_column :products, :gift_wrap, :integer
    # remove_column :products, :weight, :string

    # remove_reference :product_specifications, :technical
    # add_reference :product_specifications, :spec_item, foreign_key: {to_table: :technical_spec_items}, after: 'product_id'
    add_column :product_categories, :name_en, :string, after: 'name'
  end
end
