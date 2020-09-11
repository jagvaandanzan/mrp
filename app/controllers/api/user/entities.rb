module API
  module USER
    module Entities

      class User < Grape::Entity
        expose :name, :uid, :email, :phone
      end

      class Salesman < Grape::Entity
        expose :id, :id_number, :surname, :name, :avatar, :avatar_tumb
      end

      class SalesmanTravels < Grape::Entity
        expose :id, :id_number, :load_at, :delivery_at, :sign_at, :load_at, :load_count, :load_sum
        expose :salesman, using: API::USER::Entities::Salesman
      end

      class ProductFeatureItem < Grape::Entity
        expose :id, :name, :barcode
      end

      class ProductWarehouse < Grape::Entity
        expose :id, :barcode, :name, :code, :desk, :feature, :image, :quantity, :load_at
      end

      class SalesmanAvatar < Grape::Entity
        expose :name, :avatar_tumb
      end

      class Notification < Grape::Entity
        expose :created_at, :title, :body_s, :salesman_travel_id, :product_sale_item_id
        expose :salesman, using: API::USER::Entities::SalesmanAvatar
      end

    end
  end
end
