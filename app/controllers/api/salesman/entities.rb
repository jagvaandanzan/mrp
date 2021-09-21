module API
  module SALESMAN
    module Entities

      class Salesman < Grape::Entity
        expose :name, :uid, :email, :phone
      end

      class SalesmanTravels < Grape::Entity
        expose :id, :id_number, :distance, :duration, :wage, :sign_at, :load_at, :delivery_at, :delivered_at, :delivery_time, :route_count, :product_count, :return_count
      end

      class SalesmanTravelRoutes < Grape::Entity
        expose :id, :queue, :distance, :duration, :wage, :load_at, :delivery_at, :delivered_at,
               :delivery_time, :payable, :loc_name, :phone, :delivery_hour, :product_count, :return_count, :status, :latitude, :longitude
      end

      class ProductWarehouse < Grape::Entity
        expose :id, :barcode, :name, :code, :feature, :image, :quantity, :load_at, :salesman_at, :add_stock
      end

      class ProductSaleItem < Grape::Entity
        expose :id, :product_id, :quantity, :to_see, :price, :sum_price, :bought_at, :bought_quantity, :product_name, :product_image, :product_feature, :back_quantity
      end

      class ProductSaleReturn < Grape::Entity
        expose :id, :quantity, :price, :bought_quantity, :product_name, :product_code, :product_image, :product_feature, :product_barcode, :take_quantity, :take_at
      end

      class ProductSaleItemDetail < ProductSaleItem
        expose :product_code
      end

      class ProductSaleItemBarCode < ProductSaleItem
        expose :product_barcode
      end

      class ProductSaleItemReturn < ProductSaleItemBarCode
        expose :back_request, :return_signed
      end
      class ProductSaleReturnReturn < Grape::Entity
        expose :back_request, :return_signed, :product_image, :product_barcode, :product_code, :product_feature, :product_name, :quantity, :back_quantity
      end

      class ProductSale < Grape::Entity
        expose :id, :phone, :delivery_hour, :status_name, :status_note, :money, :paid, :sum_price, :loc_note, :building_code
        expose :product_sale_items, using: API::SALESMAN::Entities::ProductSaleItemBarCode
        expose :product_sale_returns, using: API::SALESMAN::Entities::ProductSaleReturn
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

      class ReportCash < Grape::Entity
        expose :sale_type, :product_code, :product_name, :product_feature, :phone, :bought_quantity, :bought_price
      end

      class TravelRouteDaily < Grape::Entity
        expose :day, :wage, :delivered, :distribution
      end

      class Notification < Grape::Entity
        expose :created_at, :title, :body_s, :avatar_s, :salesman_travel_id, :product_sale_item_id
      end

      class SalesmanReturnSign < Grape::Entity
        expose :id, :salesman_name, :products
      end

      class SalesmanReturn < Grape::Entity
        expose :id, :quantity, :product_code, :product_name, :product_image, :product_feature, :product_barcode, :barcode, :is_check
      end

    end
  end
end
