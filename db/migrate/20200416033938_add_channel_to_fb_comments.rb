class AddChannelToFbComments < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_comments, :channel, :integer, after: 'message'
    remove_column :fb_comments, :post_id, :string
    add_reference :fb_comments, :fb_comment, foreign_key: {to_table: :fb_comments}, after: 'fb_post_id'
    add_column :fb_posts, :comments, :integer, default: 0, after: 'product_code'
    add_column :fb_comments, :tags, :string, after: 'answered'

    remove_column :fb_comments, :answered, :boolean
    add_reference :fb_comments, :reply, foreign_key: {to_table: :fb_comments}, after: 'fb_comment_id'

  end
end
