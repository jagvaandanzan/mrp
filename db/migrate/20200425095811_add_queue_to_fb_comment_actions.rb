class AddQueueToFbCommentActions < ActiveRecord::Migration[5.2]
  def change
    change_column :salesmen, :phone, :integer
  end
end
