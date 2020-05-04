class CreateFbCommentAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_comment_answers do |t|
      t.references :operator, foreign_key: true
      t.references :user, foreign_key: true
      t.text :answer
      t.integer :used, default: 0

      t.timestamps
    end
  end
end
