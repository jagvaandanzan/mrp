class ProductSizeInstruction < ApplicationRecord
  belongs_to :product
  belongs_to :size_instruction

  validates :instruction, presence: true

  validates_uniqueness_of :size_instruction_id, scope: [:product_id]
end
