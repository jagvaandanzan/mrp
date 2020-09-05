class Users::ProductIncomesController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_income, only: [:edit, :update, :show, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_income_code = params[:by_income_code]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]

    @product_income_items = ProductIncomeItem.search(@by_start, @by_end, @by_income_code, @by_code, @by_product_name).page(params[:page])
  end

  def new
    @product_income = ProductIncome.new
    @product_income.income_date = Time.current
    @product_income.code = ApplicationController.helpers.get_code(ProductIncome.last)

    ShippingUbItem.find_to_incomes.each do |ub_item|
      @product_income.product_income_items << ProductIncomeItem.new(shipping_ub_item: ub_item,
                                                                    supply_feature: ub_item.product_supply_feature,
                                                                    remainder: ub_item[:remainder],
                                                                    product: ub_item.product,
                                                                    feature_item: ub_item.product_supply_feature.feature_item)
    end
  end

  def create
    @product_income = ProductIncome.new(product_income_params)
    if @product_income.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'show', id: @product_income.id
    else
      logger.info("error: #{@product_income.errors.full_messages}")
      render 'new'
    end
  end

  def edit
    @product_income.product_income_items.each do |item|
      item.remainder = item.shipping_ub_item.loaded
      item.income_locations.each {|loc|
        if loc.location.present?
          loc.x = loc.location.x
          loc.y = loc.location.y
          loc.z = loc.location.z
        end
      }
    end
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

  private

  def set_product_income
    @product_income = ProductIncome.find(params[:id])
  end

  def product_income_params
    params.require(:product_income).permit(:code, :income_date, :cargo_price, :logistic_id,
                                           product_income_items_attributes: [:id, :product_id, :shipping_ub_item_id, :supply_feature_id, :feature_item_id, :remainder, :quantity, :cargo, :qr_printed, :problematic, :_destroy,
                                                                             income_locations_attributes: [:id, :x, :y, :z, :quantity, :_destroy]])
        .merge(:user => current_user)
  end
end
