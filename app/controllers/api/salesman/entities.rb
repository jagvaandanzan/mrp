module API
  module SALESMAN
    module Entities

      class ProductFeature < Grape::Entity
        expose :method, :id, :queue, :name, :description
      end

    end
  end
end
