class Users::ProductSupplyOrdersController < Users::BaseController
  before_action :set_product_supply_order, only: [:edit, :update, :destroy]

  def index
    @by_code = params[:by_code]
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @supply_orders = ProductSupplyOrder.search(@by_code, @by_start, @by_end).page(params[:page])
  end

  def new
    @product_supply_order = ProductSupplyOrder.new
    @product_supply_order.ordered_date = Time.current
  end

  def create
    @product_supply_order = ProductSupplyOrder.new(product_supply_order_params)
    if @product_supply_order.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @product_supply_order.attributes = product_supply_order_params
    if @product_supply_order.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @product_supply_order.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: 'index'
  end

  private

  def set_product_supply_order
    @product_supply_order = ProductSupplyOrder.find(params[:id])
  end

  def product_supply_order_params
    params.require(:product_supply_order).permit(:code, :ordered_date, :supplier_id, :payment, :exchange, :exchange_value, :is_closed, :closed_date)
  end
end
