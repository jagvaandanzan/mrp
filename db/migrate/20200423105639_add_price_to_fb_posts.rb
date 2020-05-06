class AddPriceToFbPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_comments, :is_visible, :boolean, default: true, after: 'fb_post_id'

    create_table :uploads do |t|
      t.attachment :image

      t.timestamps
    end

  end
end
