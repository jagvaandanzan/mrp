class CreateFbCommentReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_comment_reactions do |t|
      t.references :fb_post, foreign_key: true
      t.string :post_id
      t.string :user_id
      t.integer :reaction

      t.timestamps
    end
  end
end
