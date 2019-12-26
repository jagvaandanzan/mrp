module API
  module SALESMAN
    class Sales < Grape::API
      resource :sales do
        resource :products do
          resource :available do
            desc "GET sales/products/available"
            get do
              products = Product.sale_available(current_salesman.id)
              present :products, products, with: API::SALESMAN::Entities::ProductSearch
            end
          end

          route_param :id do
            resource :items do
              desc "GET sales/products/:id/items"
              get do
                product_feature_items = ProductFeatureItem.sale_available(current_salesman.id, params[:id])
                present :feature_items, product_feature_items, with: API::SALESMAN::Entities::ProductFeatureItems
              end

              route_param :f_item_id do
                resource :quantity do
                  desc "GET sales/products/:id/items/:f_item_id/quantity"
                  get do
                    quantity = ProductFeatureItem.sale_available_item_quantity(current_salesman.id, params[:f_item_id])
                    present :available_quantity, quantity
                  end
                end
              end
            end
          end
        end

        resource :travels do

          resource :get_balance do
            desc "GET travels/get_balance"
            params do
              requires :email, type: String
            end
            post do
              feature_item_id = params[:feature_item_id]
              product_balance = ProductBalance.balance(params[:product_id], feature_item_id)
              feature_item = ProductFeatureItem.find(feature_item_id)
              feature_rel = feature_item.feature_rel
              render json: {balance: product_balance, img: feature_rel.image.present? ? feature_rel.image.url : '/assets/no-image.png', tumb: feature_rel.image.present? ? feature_rel.image.url(:tumb) : '/assets/no-image.png'}
            end
          end
        end
      end
    end
  end
end