class ProductFeatureOption < ApplicationRecord
  acts_as_paranoid

  belongs_to :product_feature
  has_many :product_feature_option_rels, :class_name => "ProductFeatureOptionRel", :foreign_key => "feature_option_id", dependent: :destroy

  validates :name, presence: true

  scope :search, ->(f_id, sname) {
    items = where(product_feature_id: f_id)
    items = items.where('name LIKE :value', value: "%#{sname}%") if sname.present?
    items.order(:queue)
        .order(:name)
  }

end
