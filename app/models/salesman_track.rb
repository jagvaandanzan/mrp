class SalesmanTrack < ApplicationRecord
  belongs_to :salesman

  scope :by_date, ->(date) {
    select("MAX(salesman_tracks.id) as id")
        .left_joins(:salesman)
        .where('salesman_tracks.created_at >= ?', date)
        .where('salesman_tracks.created_at < ?', date + 1.days)
        .group("salesmen.id")
  }

  scope :by_ids, ->(ids) {
    where("id IN (?)", ids)
  }
end
