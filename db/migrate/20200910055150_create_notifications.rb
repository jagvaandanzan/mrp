class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    # create_table :notifications do |t|
    #   t.references :user, foreign_key: true
    #   t.references :salesman, foreign_key: true
    #   t.references :salesman_travel, foreign_key: true
    #   t.references :product_sale_item, foreign_key: true
    #   t.string :title
    #   t.string :body_s
    #   t.string :body_u
    #   t.integer :n_type, default: 0
    #
    #   t.timestamps
    # end
    # add_column :product_feature_items, :real_img, :boolean, default: false, after: 'image_file_name'
    # change_column :product_size_instructions, :instruction, :string
    # add_column :customers, :c_type, :integer, after: 'id'
    add_reference :product_sample_images, :product_supply_order, foreign_key: true, after: 'id'
    remove_reference :product_sample_images, :product_sample
    remove_reference :product_supply_order_items, :product_sample
    add_column :product_supply_orders, :order_type, :integer, after: 'id'
    add_column :product_supply_orders, :link, :text, after: 'exchange'
    add_column :product_supply_orders, :description, :text, after: 'link'

  end
end
