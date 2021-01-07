class Users::ProductIncomesController < Users::BaseController
  load_and_authorize_resource :except => [:insert_shipping_ub]
  before_action :set_product_income, only: [:edit, :update, :show, :locations, :set_location, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_product_name = params[:by_product_name]
    @product_income_products = ProductIncomeProduct.search(@by_start, @by_end, @by_product_name).page(params[:page])
  end

  def new
    @product_income = ProductIncome.new
    @product_income.income_date = Time.current
    @product_income.number = ApplicationController.helpers.last_number(ProductIncome)
    # ShippingUbProduct.find_to_incomes.each do |ub_product|
    #   @product_income.product_income_products << ProductIncomeProduct.new(shipping_ub_product_id: ub_product.id,
    #                                                                       product_id: ub_product.product_id,
    #                                                                       remainder: ub_product[:remainder])
    # end
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
    @shipping_ub_product = ShippingUbProduct.find_to_incomes(params[:id]).first
    @rows = params[:rows].to_i
    respond_to do |format|
      format.js {render 'users/product_incomes/add_product'}
    end
  end

  def edit
  end

  def show
  end

  def update
    @product_income.attributes = product_income_params
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

  private

  def set_product_income

  end

  def product_income_params
    params.require(:product_income).permit(:income_date, :cargo_price, :logistic_id,
                                           product_income_products_attributes: [:id, :product_id, :shipping_ub_product_id, :remainder, :quantity, :cargo, :_destroy])
        .merge(:user => current_user)
  end

  def income_location_params
    params.require(:product_income).permit(product_income_items_attributes: [:id, :qr_printed, :problematic, :_destroy,
                                                                             income_locations_attributes: [:id, :x, :y, :z, :quantity, :_destroy]])
  end
end
