class CreateFbCommentArchives < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_comment_archives do |t|
      t.references :fb_post, null: false, foreign_key: true
      t.references :archive, {to_table: :fb_comment_archives}
      t.text :message
      t.string :comment_id
      t.string :parent_id
      t.string :user_id
      t.string :user_name
      t.datetime :date
      t.datetime :deleted_at

      t.timestamps
    end

    add_column :fb_posts, :deleted_at, :datetime, after: 'comments'
    remove_column :fb_posts, :comments

  end
end
