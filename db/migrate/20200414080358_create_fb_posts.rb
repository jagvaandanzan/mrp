class CreateFbPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_posts do |t|
      t.string :post_id
      t.string :product_name
      t.string :product_code

      t.timestamps
    end
    add_reference :fb_comments, :fb_post, foreign_key: true, after:'id'
  end
end
