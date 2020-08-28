class Logistics::ShippingUbsController < Logistics::BaseController
  before_action :set_shipping_ub, only: [:show, :edit, :update, :destroy]

  def index
    @product_name = params[:product_name]
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @shipping_ubs = ShippingUb.search(@by_start, @by_end, @product_name).page(params[:page])
    cookies[:shipping_ub_page_number] = params[:page]
  end

  def new
    @shipping_ub = ShippingUb.new
    @shipping_ub.date = Time.current
    ShippingErItem.find_to_ub.each do |er_item|
      @shipping_ub.shipping_ub_items << ShippingUbItem.new(shipping_er_item: er_item,
                                                           product_supply_feature: er_item.product_supply_feature,
                                                           remainder: er_item[:remainder],
                                                           product: er_item.product)
    end
  end

  def create
    @shipping_ub = ShippingUb.new(shipping_ub_params)

    if @shipping_ub.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      logger.info("errors: #{@shipping_ub.errors.full_messages}")
      render 'new'
    end
  end

  def show
  end

  def edit
    @shipping_ub.shipping_ub_items.each do |item|
      item.remainder = (ShippingErItem.sum_received(item.product_supply_feature_id) - ShippingUbItem.sum_loaded(item.product_supply_feature_id)) + item.loaded
    end
  end

  def update
    @shipping_ub.attributes = shipping_ub_params
    if @shipping_ub.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @shipping_ub.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_shipping_ub
    @shipping_ub = ShippingUb.find(params[:id])
  end

  def shipping_ub_params
    params.require(:shipping_ub).permit(:date, :description,
                                        shipping_ub_items_attributes: [:id, :product_id, :product_supply_feature_id, :shipping_er_item_id, :remainder, :loaded, :same_item_id, :cargo, :s_type, :cost, :_destroy])
        .merge(:logistic => current_logistic)
  end
end