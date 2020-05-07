class AddVerbToFbCommentArchives < ActiveRecord::Migration[5.2]
  def change
    add_reference :fb_posts, :fb_post, foreign_key: {to_table: :fb_posts}, after:'id'
  end
end
