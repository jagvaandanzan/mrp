class Logistics::SupplyOrdersController < Logistics::BaseController
  before_action :set_supply_order_item, only: [:edit, :show, :update]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]
    cookies[:product_supply_order_page_number] = params[:page]

    @product_supply_order_items = ProductSupplyOrderItem.search(@by_start, @by_end, @by_code, @by_product_name).page(params[:page])
  end

  def edit
  end

  def show
  end

  def update
    @supply_order_item.attributes = supply_order_item_params
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
    params.require(:product_supply_order_item).permit(:note_lo,
                                                      supply_features_attributes: [:id, :is_update, :quantity_lo, :price_lo, :note_lo, :_destroy])
        .merge(:logistic => current_logistic)
  end
end
