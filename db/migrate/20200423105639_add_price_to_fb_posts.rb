class AddPriceToFbPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_posts, :price, :integer, after: 'product_code'
    add_column :fb_posts, :feature, :text, after: 'price'
  end
end
