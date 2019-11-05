class UserPermission < ApplicationRecord
  has_many :user_permission_rels, dependent: :destroy

  scope :by_queue, ->() {
    order(:queue)
  }

end
