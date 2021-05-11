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
        expose :id, :barcode, :product_id, :product_name, :name, :image_url, :quantity
      end

      class ProductWarehouse < Grape::Entity
        expose :id, :barcode, :name, :code, :desk, :feature, :image, :quantity, :load_at, :add_stock
      end

      class Products < Grape::Entity
        expose :id, :code, :name
      end

      class ProductFeatures < Grape::Entity
        expose :id, :name, :balance, :price
      end

      class SalesmanTravelRoutes < Grape::Entity
        expose :id, :queue, :loc_name, :phone, :product_count, :product_sale_id
      end

      class Notification < Grape::Entity
        expose :created_at, :title, :body_u, :avatar_u, :salesman_travel_id, :product_sale_item_id
      end

      class SalesmanReturnSign < Grape::Entity
        expose :id, :salesman_name, :products
      end

      class SalesmanReturn < Grape::Entity
        expose :id, :quantity, :product_code, :product_name, :product_image, :product_feature, :product_barcode
      end

      class ProductFeatureItemList < Grape::Entity
        expose :id, :barcode, :product_name, :name, :thumb_url, :image_url
      end

      class LocationTransferItem < Grape::Entity
        expose :id, :quantity, :transferred, :desk
        expose :product_feature_item, using: API::USER::Entities::ProductFeatureItemList
      end

      class LocationTransfer < Grape::Entity
        expose :id, :location_name
        expose :product_location_trans_items, using: API::USER::Entities::LocationTransferItem
      end

      class LocationTransferList < Grape::Entity
        expose :id, :location_name, :quantity, :transferred
      end

    end
  end
end
