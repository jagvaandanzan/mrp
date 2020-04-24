class AddFbCommentActionToFbCommentArchives < ActiveRecord::Migration[5.2]
  def change
    add_reference :fb_comment_archives, :comment_action, foreign_key: { to_table: :fb_comment_actions }, after: 'fb_post_id'
  end
end
