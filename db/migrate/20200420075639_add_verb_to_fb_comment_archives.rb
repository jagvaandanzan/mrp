class AddVerbToFbCommentArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_comment_archives, :verb, :integer, after: 'message', default: 0
  end
end
