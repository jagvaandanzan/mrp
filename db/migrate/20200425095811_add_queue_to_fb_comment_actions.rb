class AddQueueToFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    # add_column :fb_comment_archives, :photo, :text, after: 'date'
    change_column :bank_transactions, :summary, :float
  end
end
