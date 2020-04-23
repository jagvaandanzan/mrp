class OperatorPermission < ApplicationRecord
  has_many :operator_permission_rels, dependent: :destroy

  scope :by_queue, ->() {
    order(:queue)
  }
end
