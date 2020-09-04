module API
  module USER
    module Entities

      class Salesman < Grape::Entity
        expose :id, :id_number, :surname, :name, :avatar, :avatar_tumb
      end

      class SalesmanTravels < Grape::Entity
        expose :id, :id_number, :load_at, :delivery_at, :sign_at, :load_at, :load_count, :load_sum
        expose :salesman, using: API::USER::Entities::Salesman
      end

      class ProductWarehouse < Grape::Entity
        expose :id, :barcode, :name, :code, :desk, :feature, :image, :quantity, :load_at
      end

    end
  end
end
