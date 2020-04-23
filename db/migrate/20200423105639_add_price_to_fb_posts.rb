class AddPriceToFbPosts < ActiveRecord::Migration[5.2]
  def change
    change_column :fb_posts, :price, :string
  end
end
