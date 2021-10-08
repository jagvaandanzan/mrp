class Users::ProductIncomesController < Users::BaseController
  load_and_authorize_resource :except => [:insert_shipping_ub, :insert_half_ub, :insert_sample_product]
  before_action :set_product_income, only: [:edit, :update, :show, :locations, :set_location, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_product_name = params[:by_product_name]
    @order_type = params[:order_type]
    @product_income_products = ProductIncomeProduct.search(@by_start, @by_end, @by_product_name, @order_type)
                                   .page(params[:page])
    @product_income_products_all = ProductIncomeProduct.search(@by_start, @by_end, @by_product_name, @order_type)
  end

  def new
    @product_income = ProductIncome.new
    @product_income.income_date = Time.current
    @product_income.number = ApplicationController.helpers.last_number(ProductIncome)
    # ShippingUbProduct.find_to_incomes.each do |ub_product|
    #   income_product = ProductIncomeProduct.new(shipping_ub_product_id: ub_product.id,
    #                                             product_id: ub_product.product_id,
    #                                             remainder: ub_product[:remainder])
    #   ub_product.shipping_ub_features
    #       .by_quantity(0).each {|ub_feature|
    #     income_product.product_income_items << ProductIncomeItem.new(is_income_order: true,
    #                                                                  shipping_ub_feature: ub_feature,
    #                                                                  product_id: ub_product.product_id,
    #                                                                  supply_feature: ub_feature.supply_feature,
    #                                                                  feature_item: ub_feature.feature_item,
    #                                                                  remainder: ub_feature.quantity)
    #   }
    #   @product_income.product_income_products << income_product
    # end
  end

  def search_products
    shipping_ub_products = ShippingUbProduct.find_to_incomes(nil, nil, params[:by_product_name], params[:ids])
    respond_to do |format|
      format.js {render 'users/product_incomes/search_ub_product_js', locals: {shipping_ub_products: shipping_ub_products, page: params[:page]}}
    end
  end

  def search_half_products
    shipping_ub_products = ShippingUbProduct.find_half(nil, nil, params[:by_half_code], params[:ids])
    respond_to do |format|
      format.js {render 'users/product_incomes/search_half_products_js', locals: {shipping_ub_products: shipping_ub_products, page: params[:page]}}
    end
  end

  def search_supply_feature
    product_supply_features = ProductSupplyFeature.find_to_income(1, nil, params[:by_code], params[:by_product_name], params[:product_ids])
    respond_to do |format|
      format.js {render 'users/product_incomes/search_supply_feature_js', locals: {product_supply_features: product_supply_features, page: params[:page]}}
    end
  end

  def create
    @product_income = ProductIncome.new(product_income_params)
    if @product_income.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'show', id: @product_income.id
    else
      logger.info("error: #{@product_income.errors.full_messages}")
      @product_income.product_income_products.each do |i_p|
        logger.info("error p: #{i_p.errors.full_messages}")
        i_p.product_income_items.each do |i|
          logger.info("error i: #{i.errors.full_messages}")
        end
      end
      @product_income.number = ApplicationController.helpers.last_number(ProductIncome)
      render 'new'
    end
  end

  def insert_shipping_ub
    @shipping_ub_products = ShippingUbProduct.find_to_incomes(params[:is_box] == "true", params[:id].to_i, nil, params[:ids])
    @rows = params[:rows].to_i
    respond_to do |format|
      format.js {render 'users/product_incomes/add_product'}
    end
  end

  def insert_half_ub
    @shipping_half_products = ShippingUbProduct.find_half(params[:is_box] == "true", params[:id].to_i, nil, params[:ids])
    @row = params[:row].to_i
    respond_to do |format|
      format.js {render 'users/product_incomes/add_half_product'}
    end
  end

  def insert_sample_product
    @product_id = params[:id]
    @product_supply_features = ProductSupplyFeature.find_to_income(1, params[:id], params[:by_code], params[:by_product_name],  params[:product_ids])
    @rows = params[:rows].to_i
    @sample_box_id = params[:sample_box_id]
    respond_to do |format|
      format.js {render 'users/product_incomes/add_sample_product'}
    end
  end

  def edit
    # @product_income.product_income_products.each do |income_product|
    #   income_product.remainder = income_product.shipping_ub_product.quantity
    # end
  end

  def show
  end

  def update
    @product_income.attributes = product_income_params
    @product_income.user = current_user
    if @product_income.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      logger.info("error: #{@product_income.errors.full_messages}")
      render 'edit'
    end
  end

  def destroy
    @product_income.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  def get_supply_order_info
    @supply_order_item = nil
    @features = nil
    if params[:order_item_id].present?
      @supply_order_item = ProductSupplyOrderItem.find_by!(id: params[:order_item_id])
    end

    if @supply_order_item.present?
      @features = ProductFeatureItem.search(@supply_order_item.product_id)
      feature_arr = []
      @features.each do |item|
        feature_arr.push({id: item.id, name: item.name})
      end

      render json: {order_code: @supply_order_item.product_supply_order.code,
                    exchange: @supply_order_item.product_supply_order.exchange_i18n,
                    exchange_value: ApplicationController.helpers.get_currency_mn(@supply_order_item.product_supply_order.exchange_value),
                    remainder: ProductIncomeBalance.balance(@supply_order_item.product_id),
                    price: @supply_order_item.price,
                    shuudan: @supply_order_item.shuudan,
                    features: feature_arr}
    else
      render json: {}
    end
  end

  def locations
    redirect_to action: 'index'
    @product_income.product_income_items.each do |item|
      # item.remainder = item.shipping_ub_feature.quantity
      item.income_locations.each {|loc|
        if loc.location.present?
          loc.x = loc.location.x
          loc.y = loc.location.y
          loc.z = loc.location.z
        end
      }
    end
  end

  def set_location
    @product_income.attributes = income_location_params
    if @product_income.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'locations'
    end
  end

  def income_logs
    @manage_log = params[:manage_log].present? ? params[:manage_log] == "true" : (can? :manage, ProductIncomeLog)
    @product_income_logs = ProductIncomeLog.by_income_item_id(params[:income_item_id])
    respond_to do |format|
      format.js {render 'users/product_incomes/income_logs_js'}
    end
  end

  def update_income_log
    income_log = ProductIncomeLog.find(params[:item_log_id])
    income_log.is_match = params[:is_ok]
    income_log.description = params[:description]
    income_log.user = current_user if income_log.is_match
    income_log.save

    is_match = true
    income_log.product_income_item.product_income_logs.each do |log|
      is_match = false unless log.is_match
    end
    income_log.product_income_item.update_column(:is_match, is_match)
  end

  private

  def set_product_income
    @product_income = ProductIncome.find(params[:id])
  end

  def product_income_params
    params.require(:product_income).permit(:income_date, :cargo_price, :logistic_id,
                                           product_income_products_attributes: [:id, :product_id, :shipping_ub_product_id, :shipping_ub_sample_id, :product_supply_order_id, :cargo, :_destroy,
                                                                                product_income_items_attributes: [:id, :is_income_order, :product_id, :shipping_ub_feature_id, :supply_feature_id, :feature_item_id, :remainder, :quantity, :_destroy]])
        .merge(:user => current_user)
  end

  def income_location_params
    params.require(:product_income).permit(product_income_items_attributes: [:id, :qr_printed, :problematic, :_destroy,
                                                                             income_locations_attributes: [:id, :x, :y, :z, :quantity, :_destroy]])
  end
end
