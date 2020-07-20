class ProductName < ApplicationRecord
  enum n_type: {m_name: 0, m_number: 1, packaging: 2, material: 3, advantages: 4}

  with_options :if => Proc.new {|m| m.name.present?} do
    validates :name, length: {maximum: 255}
  end
end
