module API
  module V1
    module Entities

      class ProductFeature < Grape::Entity
        expose :method, :id, :queue, :name, :description
      end

    end
  end
end
