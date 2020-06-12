class ProductSizeInstruction < ApplicationRecord
  belongs_to :product
  belongs_to :product_feature_option
  belongs_to :size_instruction

  validates :instruction, presence: true

  scope :by_size_feature, ->(size_id, feature_id) {
    where(size_instruction_id: size_id)
        .where(product_feature_option_id: feature_id)
  }

end
