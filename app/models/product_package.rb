class ProductPackage < ApplicationRecord
  belongs_to :product

  enum gift_wrap: {wrap_not: 0, wrap_have: 1}
  enum package_unit: {p_ce: 0, p_m: 1}
  enum weight_unit: {w_gr: 0, w_kg: 1}

end
