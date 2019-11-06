class Users::ProductSupplyOrdersController < Users::BaseController
  load_and_authorize_resource
  before_action :set_product_supply_order, only: [:edit, :show, :update, :destroy]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]

    @product_supply_order_items = ProductSupplyOrderItem.search(@by_start, @by_end, @by_code, @by_product_name).page(params[:page])
  end

  def new
    @product_supply_order = ProductSupplyOrder.new
    @product_supply_order.ordered_date = Time.current
    @product_supply_order.code = ApplicationController.helpers.get_code(ProductSupplyOrder.last)

    @product_supply_order.product_supply_order_items << ProductSupplyOrderItem.new
  end

  def create
    @product_supply_order = ProductSupplyOrder.new(product_supply_order_params)
    if @product_supply_order.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to :action => 'show', id: @product_supply_order.id
    else
      logger.debug(@product_supply_order.errors.full_messages)
      render 'new'
    end
  end

  def edit
  end

  def show
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

  def last_product_price
    price = 0
    order_items = ProductSupplyOrderItem.where(product_id: params[:product_id])

    if order_items.present?
      price = order_items.last.price
    end

    render json: {price: price}

  end

  private

  def set_product_supply_order
    @product_supply_order = ProductSupplyOrder.find(params[:id])
  end

  def product_supply_order_params
    params.require(:product_supply_order).permit(:code, :ordered_date, :supplier_id, :payment, :exchange, :exchange_value, :is_closed, :closed_date,
                                                 product_supply_order_items_attributes: [:id, :product_id, :quantity, :price, :link, :shuudan, :note, :_destroy])
        .merge(:user => current_user)
  end
end
