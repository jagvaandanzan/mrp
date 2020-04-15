class AddParentIdToFbComments < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_comments, :parent_id, :string, after:'comment_id'
  end
end
