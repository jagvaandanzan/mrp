module API
  module V1
    module Entities

      class ProductFeature < Grape::Entity
        expose :method, :id, :queue, :name, :description
      end

      class BankTransaction < Grape::Entity
        expose :date_time, :value, :summary, :account
      end

      class ProductSaleItem < Grape::Entity
        expose :price, :bought_quantity
      end

    end
  end
end
