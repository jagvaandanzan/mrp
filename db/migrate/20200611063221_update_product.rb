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
    # add_column :product_categories, :name_en, :string, after: 'name'

    # remove_column :product_supply_order_items, :sum_tug, :float
    # remove_column :product_supply_order_items, :link, :string
    # remove_column :product_supply_features, :sum_tug, :float
    # remove_column :product_supply_orders, :exchange_value, :float
    # remove_column :product_samples, :exchange_value, :float
    # add_column :product_samples, :description, :text, after: 'user_id'
    # add_column :product_samples, :status, :integer, after: 'code', default: 0
    # add_column :product_samples, :link, :text, after: 'exchange'
    # add_column :products, :draft, :boolean, after: 'is_own', default: false
    # remove_attachment :product_supply_order_items, :image
    # add_column :product_supply_orders, :status, :integer, after: 'code', default: 0
    # remove_column :product_samples, :payment, :integer
    # remove_column :product_supply_orders, :payment, :integer
    # remove_column :product_supply_orders, :closed_date, :datetime
    # remove_column :product_supply_orders, :is_closed, :boolean
    # remove_column :products, :name_cn, :string
    # remove_column :products, :name_en, :string
    # add_column :product_packages, :bag, :string, after: 'product_size'
    # add_column :product_feature_options, :name_en, :string, after: 'name'
    # add_column :product_feature_groups, :sync_at, :datetime, after: 'code'
    # add_column :category_filter_groups, :sync_at, :datetime, after: 'name_en'
    # add_column :category_filters, :sync_at, :datetime, after: 'name_en'
    # add_column :customers, :sync_at, :datetime, after: 'description'
    # add_column :brands, :sync_at, :datetime, after: 'logo_updated_at'
    # add_column :manufacturers, :sync_at, :datetime, after: 'country'
    # add_column :technical_specifications, :sync_at, :datetime, after: 'specification_gr'
    # change_column :product_packages, :product_size, :text
    # change_column :product_packages, :bag, :integer
    add_attachment :product_videos, :image, after: 'product_id'

  end
end
