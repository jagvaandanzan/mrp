class Users::ProductIncomesController < Users::BaseController
  before_action :set_product_income, only: [:edit, :update, :show, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_income_code = params[:by_income_code]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]
    @by_type = params[:by_type]

    @product_income_items = ProductIncomeItem.search(@by_start, @by_end, @by_income_code, @by_code, @by_product_name, @by_type).page(params[:page])
  end

  def new
    # @location_arr = ApplicationController.helpers.get_all_location
    @product_income = ProductIncome.new
    @product_income.income_date = Time.current
    @product_income.code = ApplicationController.helpers.get_code(ProductIncome.last)
    item = ProductIncomeItem.new
    item.date = @product_income.income_date
    @product_income.product_income_items << item
  end

  def create
    @product_income = ProductIncome.new(product_income_params)
    if @product_income.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'show', id: @product_income.id
    else
      render 'new'
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
      @features = ProductFeatureRel.search(@supply_order_item.product_id)
      feature_arr = []
      @features.each do |item|
        feature_arr.push({id: item.id, name: item.rel_names})
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

  def get_location_children
    @locations = nil
    if params[:parent_id].present?
      @locations = ProductLocation.search(params[:parent_id])
    end

    render json: {childrens: @locations}
  end

  private

  def set_product_income
    @product_income = ProductIncome.find(params[:id])
  end

  def product_income_params
    params.require(:product_income).permit(:code, :income_date, :note,
                                           product_income_items_attributes: [:id, :supply_order_item_id, :remainder, :feature_rel_id, :quantity, :price, :shuudan, :urgent_type, :date, :note, :_destroy])
        .merge(:user => current_user)
  end
end
