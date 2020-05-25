class SizeInstruction < ApplicationRecord
  validates :instruction, presence: true, length: {maximum: 255}

  scope :order_queue, ->() {
    order(:queue)
        .order(:instruction)
  }

  scope :search, ->(search_instruction) {
    items = order_queue
    items = items.where('instruction LIKE :value', value: "%#{search_instruction}%") if search_instruction.present?
    items
  }

end
