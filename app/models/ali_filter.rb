class AliFilter < ApplicationRecord
  belongs_to :ali_filter_group

  scope :by_name, ->(name) {
    where(name: name) if name.present?
  }

  scope :name_mn_nil, ->() {
    where("name_mn IS ?", nil)
  }
  scope :mn_change, ->(bool) {
    where(mn_change: bool)
  }

end
