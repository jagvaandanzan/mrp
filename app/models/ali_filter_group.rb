class AliFilterGroup < ApplicationRecord
  belongs_to :ali_category

  has_many :filters, :class_name => "AliFilter", :foreign_key => "ali_filter_group_id"
end
