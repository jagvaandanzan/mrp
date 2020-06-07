class OperatorToFbComments < ActiveRecord::Migration[5.2]
  def change
    add_reference :fb_comments, :operator, foreign_key: true, after: 'photo'
  end
end
