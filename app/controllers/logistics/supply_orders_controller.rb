class Logistics::SupplyOrdersController < Logistics::BaseController
  before_action :set_supply_order_item, only: [:edit, :show, :update]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]
    @order_type = params[:order_type]
    cookies[:product_supply_order_page_number] = params[:page]

    @product_supply_order_items = ProductSupplyOrderItem.search(@by_start, @by_end, @by_code, @by_product_name, @order_type).page(params[:page])
  end

  def edit
  end

  def show
  end

  def update
    @supply_order_item.attributes = supply_order_item_params
    unless params[:commit] == "保存"
      @supply_order_item.status = 8
    end
    if @supply_order_item.save
      @supply_order_item.set_sum_price_lo
      flash[:success] = t('alert.info_updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  private

  def set_supply_order_item
    @supply_order_item = ProductSupplyOrderItem.find(params[:id])
  end

  def supply_order_item_params
    params.require(:product_supply_order_item).permit(:note_lo, :cn_name, :cost,
                                                      supply_features_attributes: [:id, :cn_name, :is_update, :quantity_lo, :price_lo, :note_lo, :_destroy])
        .merge(:logistic => current_logistic)
  end
end
