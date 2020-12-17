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
    @shipping_er.number = ApplicationController.helpers.last_number(ShippingEr)
  end

  def create
    @shipping_er = ShippingEr.new(shipping_er_params)

    if @shipping_er.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      logger.info("errors: #{@shipping_er.errors.full_messages}")
      @shipping_er.date = Time.current
      @shipping_er.number = ApplicationController.helpers.last_number(ShippingEr)

      render 'new'
    end
  end

  def show
  end

  def edit
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

  def add_product
    @product = Product.find(params[:product_id])
    @shipping_er_product = ShippingErProduct.new(product: @product)

    ProductSupplyFeature.find_to_er(params[:product_id]).each {|ps|
      if ps[:remainder].present? && ps[:remainder].to_i > 0
        @shipping_er_product.shipping_er_features << ShippingErFeature.new(supply_feature: ps,
                                                                           remainder: ps[:remainder],
                                                                           product: @product)
      end
    }
    @rows = params[:rows].to_i + 1
    # @shipping_er = ShippingEr.new
    # @shipping_er.shipping_er_products << @shipping_er_product
    respond_to do |format|
      format.js {render 'logistics/shipping_ers/add_product'}
    end
  end

  private

  def set_shipping_er
    @shipping_er = ShippingEr.find(params[:id])
    @shipping_er.number = params[:id]
  end

  def shipping_er_params
    params.require(:shipping_er).permit(:date, :cost, :s_type, :description,
                                        shipping_er_products_attributes: [:id, :product_id, :quantity, :cargo, :_destroy,
                                                                          shipping_er_features_attributes: [:id, :product_id, :supply_feature_id, :remainder, :quantity, :_destroy]])
        .merge(:logistic => current_logistic)
  end
end