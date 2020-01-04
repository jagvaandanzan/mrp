class AddAvatarToSalesman < ActiveRecord::Migration[5.2]
  def change
    add_attachment :salesmen, :avatar, after: 'tokens'
  end
end
