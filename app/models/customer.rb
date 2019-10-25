class Customer < ApplicationRecord
  acts_as_paranoid

  scope :order_by_name, -> {
    order(:queue)
        .order(:name)
  }

end
