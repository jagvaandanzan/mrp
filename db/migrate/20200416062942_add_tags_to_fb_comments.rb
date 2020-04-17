class AddTagsToFbComments < ActiveRecord::Migration[5.2]
  def change
    remove_column :fb_comments, :is_hide, :boolean
    remove_column :fb_comments, :fb_comment_id, :references
    remove_column :fb_comments, :reply_id, :references
    remove_column :fb_comments, :channel, :integer
    remove_column :fb_comments, :tags, :string
  end
end
