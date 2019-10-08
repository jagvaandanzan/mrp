class TravelConfig < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  scope :get_last, ->() {
    last
  }
end
