class UserPermissionRel < ApplicationRecord
  belongs_to :user
  belongs_to :user_permission

  enum role: {is_read: 0, is_manage: 1}

  validates :user_permission_id, :role, presence: true

end
