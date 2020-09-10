class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :salesman, optional: true
  belongs_to :salesman_travel, optional: true
  belongs_to :product_sale_item, optional: true

  scope :by_salesman, ->(salesman_id) {
    where(salesman_id: salesman_id)
        .or(where(n_type: 1))
        .order(created_at: :desc)
  }
  scope :by_user, ->(user_id) {
    where(user_id: user_id)
        .or(where(n_type: 1))
        .order(created_at: :desc)
  }
end
