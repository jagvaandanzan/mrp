class LocationTravel < ApplicationRecord
  belongs_to :location_from, :class_name => "Location"
  belongs_to :location_to, :class_name => "Location"

  scope :search, ->(ids) {
    from_ids = sanitize_sql_array(["location_from_id IN (?)", ids])
    to_ids = sanitize_sql_array(["location_to_id IN (?)", ids])

    where(from_ids)
        .or(where(to_ids))
  }
end
