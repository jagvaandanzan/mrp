class Logistics::SupplyOrdersController < Logistics::BaseController
  before_action :set_supply_order_item, only: [:edit, :show, :update, :create_temp]

  def index
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @by_code = params[:by_code]
    @by_product_name = params[:by_product_name]
    @is_ordered = params[:is_ordered].presence || "false"
    cookies[:supply_order_page_number] = params[:page]
    @product_supply_order_items = ProductSupplyOrderItem.search(@by_start, @by_end, @by_code, @by_product_name, params[:order_type] == "basic" ? 0 : 1, @is_ordered)
                                      .page(params[:page])
  end

  def create_temp
    @supply_order_item.attributes = supply_order_temp_params
    if @supply_order_item.save(validate: false)
      flash[:success] = t('alert.info_updated')
      redirect_to logistics_supply_orders_path(order_type: params[:order_type])
    else
      render 'show'
    end
  end

  def edit
    @supply_order_item.supply_features.each do |supply_feature|
      supply_feature.quantity_lo = supply_feature.quantity unless supply_feature.quantity_lo.present?
      supply_feature.price_lo = ApplicationController.helpers.get_f(supply_feature[:price]) unless supply_feature[:price_lo].present?
    end
  end

  def show
  end

  def update
    @supply_order_item.attributes = supply_order_item_params
    if params[:commit] == "取消" || params[:commit] == "Цуцалсан"
      @supply_order_item.status = 8
    end
    if @supply_order_item.save
      @supply_order_item.set_sum_price_lo
      flash[:success] = t('alert.info_updated')
      redirect_to logistics_supply_orders_path(order_type: @supply_order_item.order_type)
    else
      render 'edit', order_type: @supply_order_item.order_type
    end
  end

  private

  def set_supply_order_item
    @supply_order_item = ProductSupplyOrderItem.find(params[:id])
  end

  def supply_order_temp_params
    params.require(:product_supply_order_item).permit(:order_type, :pin, :note_lo)
        .merge(:logistic => current_logistic)
  end

  def supply_order_item_params
    params.require(:product_supply_order_item).permit(:order_type, :note_lo, :cn_name, :cost,
                                                      supply_features_attributes: [:id, :cn_name, :is_update, :quantity_lo, :price_lo, :note_lo, :_destroy])
        .merge(:logistic => current_logistic)
  end
end
