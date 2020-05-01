class AddQueueToFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    add_column :fb_posts, :content, :text, after: 'product_code'
    add_reference :sms_messages, :user, foreign_key: true, after: 'operator_id'
    change_column_null :sms_messages, :operator_id, true
  end
end
