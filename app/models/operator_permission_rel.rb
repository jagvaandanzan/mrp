class OperatorPermissionRel < ApplicationRecord
  belongs_to :operator
  belongs_to :operator_permission

  enum role: {is_read: 0, is_manage: 1}

  validates :operator_permission_id, :role, presence: true

end
