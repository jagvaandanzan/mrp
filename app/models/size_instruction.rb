class SizeInstruction < ApplicationRecord
  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

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

  private

  def sync_web(method)
    self.method_type = method
    url = "resources/size_instruction"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :queue, :instruction], :methods => [:method_type])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end

end
