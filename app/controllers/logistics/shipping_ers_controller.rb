class Logistics::ShippingErsController < Logistics::BaseController
  before_action :set_shipping_er, only: [:show, :edit, :update, :destroy]

  def index
    @product_name = params[:product_name]
    @by_start = params[:by_start]
    @by_end = params[:by_end]
    @shipping_ers = ShippingEr.search(@by_start, @by_end, @product_name).page(params[:page])
    cookies[:shipping_er_page_number] = params[:page]
  end

  def new
    @shipping_er = ShippingEr.new
    @shipping_er.date = Time.current
    ProductSupplyFeature.find_to_er.each do |supply_f|
      @shipping_er.shipping_er_items << ShippingErItem.new(product_supply_feature: supply_f,
                                                           remainder: supply_f[:remainder],
                                                           product: supply_f.feature_item.product)
    end
  end

  def create
    @shipping_er = ShippingEr.new(shipping_er_params)

    if @shipping_er.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      logger.info("errors: #{@shipping_er.errors.full_messages}")
      render 'new'
    end
  end

  def show
  end

  def edit
    @shipping_er.shipping_er_items.each do |item|
      item.remainder = (item.product_supply_feature.quantity_lo - ShippingErItem.sum_received(item.product_supply_feature_id)) + item.received
    end
  end

  def update
    @shipping_er.attributes = shipping_er_params
    if @shipping_er.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @shipping_er.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_shipping_er
    @shipping_er = ShippingEr.find(params[:id])
  end

  def shipping_er_params
    params.require(:shipping_er).permit(:date, :description,
                                        shipping_er_items_attributes: [:id, :product_id, :product_supply_feature_id, :remainder, :received, :cargo, :s_type, :cost, :number, :_destroy])
        .merge(:logistic => current_logistic)
  end
end