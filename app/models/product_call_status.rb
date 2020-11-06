class ProductCallStatus < ApplicationRecord
  scope :parent_nil, -> {
    where("parent_id IS ?", nil)
  }

  scope :by_not_ids, ->(ids) {
    where("id NOT IN (?)", ids)
  }

  scope :by_parent_id, ->(parent_id) {
    where(parent_id: parent_id)
  }

end
