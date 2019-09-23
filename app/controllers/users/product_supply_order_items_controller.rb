class Users::ProductSupplyOrderItemsController < Users::BaseController
  before_action :set_product_supply_order_item, only: [:edit, :update, :destroy, :show]

  def index
    @search_name = params[:product_name]
    @order = ProductSupplyOrder.find_by!(id: params[:order_id])
    @items = ProductSupplyOrderItem.search(@order.id, @search_name).page(params[:page])
  end

  def new
    @item = ProductSupplyOrderItem.new
    @item.supply_order = ProductSupplyOrder.find_by!(id: params[:order_id])
  end

  def create
    @item = ProductSupplyOrderItem.new(product_supply_order_item_params)
    if @item.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index, order_id: @item.supply_order.id
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @item.attributes = product_supply_order_item_params
    if @item.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index', order_id: @item.supply_order.id
    else
      render 'edit'
    end
  end

  def destroy
    @order_id = @item.supply_order.id

    @item.destroy!
    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index, order_id: @order_id
  end

  private

  def set_product_supply_order_item
    @item = ProductSupplyOrderItem.find(params[:id])
  end

  def product_supply_order_item_params
    params.require(:product_supply_order_item).permit(:supply_order_id, :product_id, :quantity, :price, :link, :shuudan, :note)
  end
end
