module API
  module V1
    class ProductSales < Grape::API
      resource :product_sales do
        resource :bonus do
          desc "POST product_sales/bonus"
          params do
            requires :phone, type: Integer
          end
          post do
            b_phone = BonusPhone.find_by_phone(params[:phone])
            bonus = if b_phone.present?
                      b_phone.bonu.balance
                    else
                      0
                    end
            {bonus: bonus}
          end
        end
      end

    end
  end
end