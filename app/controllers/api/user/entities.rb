module API
  module USER
    module Entities

      class Salesman < Grape::Entity
        expose :id, :id_number, :surname, :name, :avatar, :avatar_tumb
      end

      class SalesmanTravels < API::SALESMAN::Entities::SalesmanTravels
        expose :load_count
        expose :salesman, using: API::USER::Entities::Salesman
      end

      class ProductWarehouse < Grape::Entity
        expose :id, :queue, :barcode, :name, :code, :deck, :feature, :image, :quantity, :load_at
      end

    end
  end
end
