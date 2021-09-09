class LogisticPermission < ApplicationRecord
  has_many :logistic_permission_rels, dependent: :destroy

  scope :by_queue, ->() {
    order(:queue)
  }
end
