class CreateFbCommentQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_comment_questions do |t|
      t.references :fb_comment_answer, null: false, foreign_key: true
      t.references :operator, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :is_selected, default: false
      t.text :comment
      t.string :post_id
      t.string :fb_user_id

      t.timestamps
    end

    create_table :fb_comment_removes do |t|
      t.string :comment_id
      t.integer :verb
      t.text :message

      t.timestamps
    end
  end
end
