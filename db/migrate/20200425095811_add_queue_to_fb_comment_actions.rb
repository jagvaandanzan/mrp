class AddQueueToFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_comments, :photo, :text, after: 'date'
    add_column :fb_comment_archives, :photo, :text, after: 'date'
  end
end
