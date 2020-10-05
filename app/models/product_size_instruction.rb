class ProductSizeInstruction < ApplicationRecord
  belongs_to :product
  belongs_to :product_feature_option
  belongs_to :size_instruction

  validates :instruction, presence: true

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  scope :by_size_feature, ->(size_id, feature_id) {
    where(size_instruction_id: size_id)
        .where(product_feature_option_id: feature_id)
  }

  private

  def sync_web(method)
    self.method_type = method
    url = "product/size_instruction"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else
      params = self.to_json(methods: [:method_type], only: [:id, :product_id, :product_feature_option_id, :size_instruction_id, :instruction])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
