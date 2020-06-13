class ProductPackage < ApplicationRecord
  belongs_to :product

  enum gift_wrap: {wrap_not: 0, wrap_have: 1}
  enum package_unit: {p_ce: 0, p_m: 1}
  enum weight_unit: {w_gr: 0, w_kg: 1}

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
end
