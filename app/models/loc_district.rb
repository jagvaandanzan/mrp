class LocDistrict < ApplicationRecord
  has_many :loc_khoroos

  validates :name, presence: true
end
