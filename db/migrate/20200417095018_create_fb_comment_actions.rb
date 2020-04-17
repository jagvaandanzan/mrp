class CreateFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_comment_actions do |t|
      t.boolean :is_active, default: 1
      t.string :comment
      t.integer :condition
      t.string :reply_txt
      t.integer :action_type

      t.timestamps
    end
  end
end
