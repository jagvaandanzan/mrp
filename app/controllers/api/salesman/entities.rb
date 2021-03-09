module API
  module SALESMAN
    module Entities

      class Salesman < Grape::Entity
        expose :name, :uid, :email, :phone
      end

      class SalesmanTravels < Grape::Entity
        expose :id, :id_number, :distance, :duration, :wage, :sign_at, :load_at, :delivery_at, :delivered_at, :delivery_time, :route_count, :product_count
      end

      class SalesmanTravelRoutes < Grape::Entity
        expose :id, :queue, :distance, :duration, :wage, :load_at, :delivery_at, :delivered_at,
               :delivery_time, :payable, :loc_name, :phone, :product_count, :status, :latitude, :longitude
      end

      class ProductWarehouse < Grape::Entity
        expose :id, :barcode, :name, :code, :feature, :image, :quantity, :load_at, :salesman_at, :add_stock
      end

      class ProductSaleItem < Grape::Entity
        expose :id, :quantity, :to_see, :price, :sum_price, :bought_at, :bought_quantity, :product_name, :product_image, :product_feature, :back_quantity
      end

      class ProductSaleItemDetail < ProductSaleItem
        expose :product_code
      end

      class ProductSaleItemBarCode < ProductSaleItem
        expose :product_barcode
      end

      class ProductSaleItemReturn < ProductSaleItemBarCode
        expose :back_request
      end

      class ProductSale < Grape::Entity
        expose :id, :phone, :status_name, :money, :paid, :sum_price, :loc_note, :building_code
        expose :product_sale_items, using: API::SALESMAN::Entities::ProductSaleItemBarCode
      end

      class SalesmanTravelRoute < SalesmanTravelRoutes
        expose :product_sale, using: API::SALESMAN::Entities::ProductSale
      end

      class ProductSearch < Grape::Entity
        expose :id, :full_name
      end

      class ProductFeatureItems < Grape::Entity
        expose :id, :name
      end

      class SaleReport < Grape::Entity
        expose :price, :bought, :back
      end

      class Notification < Grape::Entity
        expose :created_at, :title, :body_s, :avatar_s, :salesman_travel_id, :product_sale_item_id
      end

      class SalesmanReturnSign < Grape::Entity
        expose :id, :salesman_name, :products
      end

      class SalesmanReturn < Grape::Entity
        expose :id, :quantity, :product_code, :product_name, :product_image, :product_feature, :product_barcode, :barcode
      end

    end
  end
end
