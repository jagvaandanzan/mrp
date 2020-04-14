class CreateFbComments < ActiveRecord::Migration[5.2]
  def change
    create_table :fb_comments do |t|
      t.text :message
      t.string :post_id
      t.string :comment_id
      t.string :user_id
      t.string :user_name
      t.datetime :date
      t.boolean :answered, default: 0

      t.timestamps
    end
  end
end
