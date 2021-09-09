class LogisticPermissionRel < ApplicationRecord
  belongs_to :logistic
  belongs_to :logistic_permission

  enum role: {is_read: 0, is_manage: 1}

  validates :logistic_permission_id, :role, presence: true

  validates_uniqueness_of :logistic_permission_id, scope: [:logistic_id]

end
