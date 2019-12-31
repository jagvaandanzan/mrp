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
                    feature_item = ProductFeatureItem.find(params[:f_item_id])
                    quantity = ProductFeatureItem.sale_available_item_quantity(current_salesman.id, params[:f_item_id])
                    present :available_quantity, quantity
                    present :price, feature_item.price
                  end
                end
              end
            end
          end
        end

        resource :sell do
          desc "POST sales/sell"
          params do
            requires :feature_item_id, type: Integer
            requires :phone, type: Integer
            requires :quantity, type: Integer
          end
          post do
            salesman = current_salesman
            quantity = ProductFeatureItem.sale_available_item_quantity(salesman.id, params[:feature_item_id])
            feature_item = ProductFeatureItem.find(params[:feature_item_id])
            product_sale_items = ProductSaleItem.find_by_salesman_id(feature_item.id, salesman.id)

            if feature_item.present? && product_sale_items.present?
              product_sale_item = product_sale_items.first

              sale_direct = ProductSaleDirect.new(remainder: quantity,
                                                  salesman: salesman,
                                                  phone: params[:phone],
                                                  price: feature_item.price,
                                                  product: feature_item.product,
                                                  feature_rel: feature_item.feature_rel,
                                                  feature_item: feature_item,
                                                  sale_item: product_sale_item,
                                                  quantity: params[:quantity])
              if sale_direct.save
                present :created_at, sale_direct.created_at
              else
                error!(sale_direct.errors.full_messages, 422)
              end
            end
          end
        end
      end
    end
  end
end