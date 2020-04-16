class AddTagsToFbComments < ActiveRecord::Migration[5.2]
  def change
  #   add_column :fb_comments, :replied, :boolean, default: 0, after: 'fb_post_id'
    add_column :fb_comments, :is_hide, :boolean, default: 0, after: 'fb_post_id'
  end
end
