module API
  module SALESMAN
    module Entities

      class SalesmanTravels < Grape::Entity
        expose :id, :id_number, :distance, :duration, :wage, :sign_at, :load_at, :delivery_at, :delivered_at, :delivery_time, :route_count, :product_count
      end

      class SalesmanTravelRoutes < Grape::Entity
        expose :id, :queue, :distance, :duration, :wage, :load_at, :delivery_at, :delivered_at,
               :delivery_time, :payable, :loc_name, :phone, :product_count, :latitude, :longitude
      end

      class ProductSaleItem < Grape::Entity
        expose :id, :quantity, :price, :sum_price, :bought_at, :product_name, :product_image, :product_feature
      end

      class ProductSaleItemDetail < ProductSaleItem
        expose :product_code
      end

      class ProductSaleItemBarCode < ProductSaleItem
        expose :product_barcode
      end

      class ProductSale < Grape::Entity
        expose :id, :phone, :main_status, :money, :paid, :sum_price, :loc_note, :building_code
        expose :product_sale_items, using: API::SALESMAN::Entities::ProductSaleItem
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

    end
  end
end
