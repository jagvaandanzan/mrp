class AddQueueToFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_comment_actions, :queue, :integer, after: 'id', default: 0
  end
end
