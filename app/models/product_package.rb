class ProductPackage < ApplicationRecord
  belongs_to :product

  enum bag: {box: 0, bag: 1}
  enum gift_wrap: {wrap_not: 0, wrap_have: 1}
  enum package_unit: {p_ce: 0, p_m: 1}
  enum weight_unit: {w_gr: 0, w_kg: 1}

  after_create -> {sync_web('post')}
  after_update -> {sync_web('update')}, unless: Proc.new {self.method_type == "sync"}
  after_destroy -> {sync_web('delete')}
  attr_accessor :method_type

  with_options :if => Proc.new {|m| m.tab_index.present?} do
    validates :gift_wrap, presence: :true
  end

  attr_accessor :tab_index

  def package_unit_val
    if package_unit.present?
      " #{package_unit_i18n.downcase}"
    else
      ""
    end
  end

  def weight_unit_val
    if weight_unit.present?
      " #{weight_unit_i18n.downcase}"
    else
      ""
    end
  end


  scope :sync_by_p, ->(ids) {
    where("product_id IN (?)", ids)
  }
  private

  def sync_web(method)
    self.method_type = method
    url = "product/package"

    if method == 'delete'
      params = nil
      url += "/" + id.to_s
    else

      params = self.to_json(only: [:id, :product_id, :product_size, :bag, :package_unit, :width, :height, :length, :weight, :weight_unit, :gift_wrap], :methods => [:method_type])
    end

    ApplicationController.helpers.api_request(url, method, params)
  end
end
