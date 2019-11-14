module API
  module V1
    class ProductSales < Grape::API
      resource :product_sales do
        desc "POST product_sales"
        params do
          requires :id, type: Integer
          requires :quantity, type: Integer
        end
        patch do
          Rails.logger.debug("call:" + params[:id].to_s + "==>" + params[:quantity].to_s)
          {status: 200, quantity: 19}
        end
      end

    end
  end
end