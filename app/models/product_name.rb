class ProductName < ApplicationRecord
  enum n_type: {m_name: 0, m_number: 1, packaging: 2, brand: 3, material: 4, advantages: 5}

  with_options :if => Proc.new {|m| m.name.present?} do
    validates :name, length: {maximum: 255}
  end
end
